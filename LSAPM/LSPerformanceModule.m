//
//  LSPerformanceModule.m
//  LSAPM
//
//  Created by Lumia_Saki on 2017/5/13.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSPerformanceModule.h"
#import "LSPerformanceDataModel.h"
#import "LSFPSRecorder.h"
#import "LSCPURecorder.h"
#import "LSMemoryRecorder.h"
#import "LSMonitorManager.h"

#import "LSPerformanceResponseType.h"
#import "LSStacktraceResponseType.h"

#import "LSStacktraceDataModel.h"

#import <mach/mach.h>

LSMonitor(LSPerformanceModule)

static const char *const WorkerQueueIdentifier = "com.ls.feature.cpu-usage-ticker";

@interface LSPerformanceModule ()
{
    dispatch_queue_t _cpuUsageTicksWorkerQueue;
}

@property (nonatomic, strong) LSFPSRecorder *fpsRecorder;
@property (nonatomic, strong) NSTimer *ticksTimer;

@end

@implementation LSPerformanceModule
@synthesize monitorManager = _monitorManager;

+ (NSString *)moduleIdentifier {
    return kLSPerformanceMonitorIdentifier;
}

+ (Class)dataModelClass {
    return LSPerformanceDataModel.class;
}

- (void)responseForMessage:(NSDictionary *)msg response:(void (^)(id))response {
    if (!response) {
        return;
    }
    
    NSUInteger request = [msg[LS_MODULE_SECTION_REQUEST_TYPE] unsignedIntegerValue];
    
    NSNumber *fps = nil;
    if (request & InstantFPS) {
        fps = @(self.fpsRecorder.latestFps);
    }
    
    NSNumber *currentAppCpuUsage = nil;
    if (request & CurrentAppCPUUsage) {
        currentAppCpuUsage = @(ls_current_app_cpu_usage());
    }
    
    NSNumber *appMemoryUsage = nil;
    if (request & AppMemoryUsage) {
        appMemoryUsage = @(self.memoryUsage);
    }
    
    if (request & GlobalMemoryUsage) {
        // unsupport now
    }
    
    LSPerformanceDataModel *result = [[LSPerformanceDataModel alloc] initWithBuilder:^(LSPerformanceDataModelBuilder *b) {
        b.instantFps = fps;
        b.currentAppCpu = currentAppCpuUsage;
        b.appMemoryUsage = appMemoryUsage;
    }];
    
    response(result);
}

- (void)start {
    // run on main run loop internal
    [self.fpsRecorder start];
    
    // setup cpu usage
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cpuUsageTicksWorkerQueue = dispatch_queue_create(WorkerQueueIdentifier, DISPATCH_QUEUE_SERIAL);
    });
    
    dispatch_async(_cpuUsageTicksWorkerQueue, ^{
        self.ticksTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(appCpuUsageTicks) userInfo:nil repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:self.ticksTimer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] run];
    });
}

- (void)stop {
    [self.fpsRecorder stop];
    
    dispatch_async(_cpuUsageTicksWorkerQueue, ^{
        [self.ticksTimer invalidate];
        self.ticksTimer = nil;
    });
}

#pragma mark - ApplicationStateChanged

- (void)applicationDidBecomeActive {
    [self.fpsRecorder start];
}

- (void)applicationWillResignActive {
    [self.fpsRecorder stop];
}

#pragma mark - Private

- (void)frameUpdated:(NSDictionary *)fps {
    LSDataPassToProcessorModel *model = [[LSDataPassToProcessorModel alloc] init];
    
    model.canResponse = @[kLSFloatingWindowProcessorIdentifier];
    model.eventName = kLSEventNameFPSUpdate;
    
    LSPerformanceDataModel *performace = [[LSPerformanceDataModel alloc] initWithBuilder:^(LSPerformanceDataModelBuilder *b) {
        b.currentAppCpu = @(ls_current_app_cpu_usage());
        b.instantFps = fps[@"fps"];
        b.appMemoryUsage = @(self.memoryUsage);
    }];
    
    model.performance = performace;
    
    [self.monitorManager sendUnifiedDataToDataProcessor:model];
}

- (double)memoryUsage {
    double usage = 0;
    
    if (!application_mem_usage(&usage)) {
        return 0;
    }
    
    return usage;
}

// run on _cpuUsageTicksWorkerQueue queue
- (void)appCpuUsageTicks {
    thread_t highest = 0;
    
    double usage = ls_current_app_cpu_usage_attach_with_thread(&highest);
        
    [self.monitorManager sendMessage:@{
                                       LS_MODULE_SECTION_REQUEST_TYPE: @(SpecificThreadStacktrace),
                                       @"thread": @(highest)
                                       }
                        fromModuleID:[self.class moduleIdentifier] toModuleID:kLSStacktraceMonitorIdentifier response:^(LSStacktraceDataModel *res) {
                            if ([res isKindOfClass:LSStacktraceDataModel.class]) {
                                LSDataPassToProcessorModel *model = [[LSDataPassToProcessorModel alloc] init];
                                
                                model.canResponse = @[kLSPersistenceProcessorIdentifier];
                                model.eventName = kLSEventNameCpuUsageTicks;
                                
                                LSPerformanceDataModel *performance = [[LSPerformanceDataModel alloc] initWithBuilder:^(LSPerformanceDataModelBuilder *b) {
                                    b.currentAppCpu = @(usage);
                                }];
                                
                                LSStacktraceDataModel *stacktrace = [[LSStacktraceDataModel alloc] initWithBuilder:^(LSStacktraceDataBuilder *b) {
                                    b.stacktrace = fetchLatestOneLineInvocation(res.stacktrace);
                                }];
                                
                                model.performance = performance;
                                model.stacktrace = stacktrace;
                                
                                [self.monitorManager sendUnifiedDataToDataProcessor:model];
                            }
                        }
     ];
}

static inline NSString *fetchLatestOneLineInvocation(NSString *content) {
    return clipLatest(content, 1);
}

static inline NSString *clipLatest(NSString *content, NSUInteger count) {
    NSArray *a = [content componentsSeparatedByString:@"\n"];
    
    NSMutableString *result = [[NSMutableString alloc] init];
    
    // stacktrace first line is thread name description, skip it
    for (NSInteger i = 1; i < a.count; i++) {
        if (i == count + 1) {
            break;
        }
        
        NSString *substring = a[i];
        
        [result appendString:substring];
        [result appendString:@"\n"];
    }
    
    return result.copy;
}

#pragma mark - Getter

- (LSFPSRecorder *)fpsRecorder {
    if (!_fpsRecorder) {
        _fpsRecorder = [[LSFPSRecorder alloc] init];
        __weak typeof(self) weakSelf = self;
        _fpsRecorder.frameUpdated = ^(NSDictionary *fpsData) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf frameUpdated:fpsData];
        };
    }
    return _fpsRecorder;
}

@end
