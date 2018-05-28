//
//  LSANRModule.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/14.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSANRModule.h"
#import "LSANRRecorder.h"
#import "LSMonitorManager.h"
#import "LSDataPassToProcessorModel.h"

#import "LSPerformanceResponseType.h"
#import "LSStacktraceResponseType.h"

LSMonitor(LSANRModule)

static const double Default_Threshold = 3;

@interface LSANRModule ()

@property (nonatomic, strong) LSANRRecorder *anrRecorder;

@end

@implementation LSANRModule

@synthesize monitorManager = _monitorManager;

- (void)dealloc {
    [self.anrRecorder cancel];
}

- (void)start {
    [self.anrRecorder start];
}

- (void)stop {
    [self.anrRecorder cancel];
}

+ (NSString *)moduleIdentifier {
    return kLSANRMonitorIdentifier;
}

+ (Class)dataModelClass {
    return nil;
}

- (void)responseForMessage:(NSDictionary *)msg response:(void (^)(id))response {}

- (void)mainThreadBlockHandler {
    __block LSStacktraceDataModel *stacktrace = nil;
    __block LSPerformanceDataModel *performance = nil;
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    [self.monitorManager sendMessage:@{LS_MODULE_SECTION_REQUEST_TYPE: @(MainThreadStacktrace)} fromModuleID:[self.class moduleIdentifier] toModuleID:kLSStacktraceMonitorIdentifier response:^(LSStacktraceDataModel *res) {
        stacktrace = res;
        
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [self.monitorManager sendMessage:@{LS_MODULE_SECTION_REQUEST_TYPE: @(AppMemoryUsage | CurrentAppCPUUsage)} fromModuleID:[self.class moduleIdentifier] toModuleID:kLSPerformanceMonitorIdentifier response:^(LSPerformanceDataModel *res) {
        performance = res;
        
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, LSGetMonitorManagerQueue(), ^{
        LSDataPassToProcessorModel *model = [LSDataPassToProcessorModel new];
        
        model.canResponse = @[kLSLoggerProcessorIdentifier, kLSFloatingWindowProcessorIdentifier];
        model.eventName = kLSEventNameAnr;
        
        model.performance = performance;
        model.stacktrace = stacktrace;
        
        [self.monitorManager sendUnifiedDataToDataProcessor:model];
    });
}

#pragma mark - Private

- (LSANRRecorder *)anrRecorder {
    if (!_anrRecorder) {
        __weak typeof(self) weakSelf = self;
        _anrRecorder = [[LSANRRecorder alloc] initWithThreshold:Default_Threshold blockHandler:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf mainThreadBlockHandler];
        }];
    }
    
    return _anrRecorder;
}

@end
