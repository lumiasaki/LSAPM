//
//  LSAPM.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/10.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSAPM.h"
#import "LSMonitorManager.h"
#import "LSAPMConfiguration.h"
#import "LSDataProcessManager.h"
#import "LSUtils.h"
#import "LSRegisterHelper.h"

#import "LSFloatingWindowProcessor.h"

@interface LSAPM ()

@property (nonatomic, strong, readwrite) LSMonitorManager *monitorManager;
@property (nonatomic, strong, readwrite) LSDataProcessManager *processManager;
@property (nonatomic, assign, readwrite) BOOL running;

@end

@implementation LSAPM

#pragma mark - Public

+ (instancetype)sharedInstance {
    static LSAPM *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LSAPM alloc] init];
    });
    
    return instance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    return self;
}

- (void)start {
    if (!self.configuration) {
        self.configuration = [[LSAPMConfiguration alloc] init];
    }
    
    NSSet<Class> *modules = [NSSet setWithArray:[LSRegisterHelper allMonitorModules]];
    NSArray<Class> *processors = [LSRegisterHelper allProcessors];
    
    [self startWithModules:modules processors:processors additionalStepsToModule:^(id<LSMonitorModule> module) {
        // TODO: 去掉uinavigationcontroller的默认支持
        //                    // special case for LSViewControllerTransitionTraceModule, if not been assigned custom LSViewControllerTransitionTraceInfoProvider, the module tries to use APIs of UINavigationController to get relevant infomation. If you assign a custom provider in 'moduleBlock' above, then there is no posibility reach block of codes below.
        //                    {
        //                        if ([module isKindOfClass:LSViewControllerTransitionTraceModule.class]) {
        //                            LSViewControllerTransitionTraceModule *transitionInfoInstance = (LSViewControllerTransitionTraceModule *)module;
        //
        //                            if (!transitionInfoInstance.transitionInfoProvider && self.navigationController) {
        //                                transitionInfoInstance.navigationControllerForDefaultProviderSetupBlock = ^(LSViewControllerTransitionInfoImplement *defaultProvider) {
        //                                    defaultProvider.navigationController = self.navigationController;
        //                                };
        //                            }
        //                        }
        //                    }
    } additionalStepsToProcessor:^(id<LSDataProcessor> processor) {
        // special case for LSFloatingWindowProcessor
        if ([processor isKindOfClass:LSFloatingWindowProcessor.class]) {
            LSFloatingWindowProcessor *flt = (LSFloatingWindowProcessor *)processor;
            
            flt.floatingWindowSuperview = self.configuration.floatingWindowSuperview;
        }
    }];
}

- (void)startWithModules:(NSSet<Class> *)modules processors:(NSArray<Class> *)processors additionalStepsToModule:(void (^)(id<LSMonitorModule>))moduleBlock additionalStepsToProcessor:(void (^)(id<LSDataProcessor>))processorBlock {
    NSAssert(self.configuration, @"should assign a configuration before monitorManager/processManager become ready");
    
    dispatch_group_t initProcessorsAndMonitors = dispatch_group_create();
    
    // init processors first, because once monitors are ready, the recorders are recording, but data need processors.
    [LSUtils asyncExecute:^{
        for (Class clz in processors) {
            if (clz) {
                id<LSDataProcessor> instance = [[clz alloc] init];
                if ([instance conformsToProtocol:@protocol(LSDataProcessor)]) {
                    instance.processManager = self.processManager;
                    if (processorBlock) {
                        processorBlock(instance);
                    }
                    
                    [self.processManager addProcessor:instance];
                }
#ifdef DEBUG
                else {
                    @throw [NSException exceptionWithName:@"Debug Warning" reason:[NSString stringWithFormat:@"%@  instance not conforms to LSDataProcessor protocol", instance] userInfo:nil];
                }
#endif
            }
        }
        
        [self.processManager ready];
    } onQueue:LSGetDataProcessManagerQueue() withGroup:initProcessorsAndMonitors autoLeave:YES];
    
    [LSUtils asyncExecute:^{
        for (Class clz in modules) {
            if (clz) {
                id<LSMonitorModule> instance = [[clz alloc] init];
                if ([instance conformsToProtocol:@protocol(LSMonitorModule)]) {
                    instance.monitorManager = self.monitorManager;
                    if (moduleBlock) {
                        moduleBlock(instance);
                    }
                    
                    [self.monitorManager addMonitorModule:instance];
                }
#ifdef DEBUG
                else {
                    @throw [NSException exceptionWithName:@"Debug Warning" reason:[NSString stringWithFormat:@"%@  instance not conforms to LSMonitorModule protocol", instance] userInfo:nil];
                }
#endif
            }
        }
        
        [self.monitorManager ready];
    } onQueue:LSGetMonitorManagerQueue() withGroup:initProcessorsAndMonitors autoLeave:YES];
    
    dispatch_group_notify(initProcessorsAndMonitors, dispatch_get_main_queue(), ^{
        self.running = YES;
    });
}

- (void)stop {
    dispatch_group_t stopAllProcessorAndMonitor = dispatch_group_create();
    
    [LSUtils asyncExecute:^{
        [self.processManager stopAll];
    } onQueue:LSGetDataProcessManagerQueue() withGroup:stopAllProcessorAndMonitor autoLeave:YES];
    
    [LSUtils asyncExecute:^{
        [self.monitorManager stopAll];
    } onQueue:LSGetMonitorManagerQueue() withGroup:stopAllProcessorAndMonitor autoLeave:YES];
    
    dispatch_group_notify(stopAllProcessorAndMonitor, dispatch_get_main_queue(), ^{
        self.running = NO;
    });
}

- (void)invalidate {
    dispatch_group_t invalidateGroup = dispatch_group_create();

    [LSUtils asyncExecute:^{
        [self.processManager stopAll];
        
        BOOL next = YES;
        do {
            id<LSDataProcessor> processor = [self.processManager.currentProcessors lastObject];
            
            next = processor != nil;
            if (processor) {
                [self.processManager removeProcessor:processor];
            }
        } while (next);                
    } onQueue:LSGetDataProcessManagerQueue() withGroup:invalidateGroup autoLeave:YES];
    
    [LSUtils asyncExecute:^{
        [self.monitorManager stopAll];
        
        BOOL next = YES;
        do {
            id<LSMonitorModule> module = [self.monitorManager.monitorModules anyObject];
            
            next = module != nil;
            
            if (module) {
                [self.monitorManager removeMonitorModule:module];
            }
        } while (next);
    } onQueue:LSGetMonitorManagerQueue() withGroup:invalidateGroup autoLeave:YES];
    
    dispatch_group_notify(invalidateGroup, dispatch_get_main_queue(), ^{
        self.running = NO;
    });
}

#pragma mark - Private

- (void)applicationWillResignActiveNotification:(__unused NSNotification *)notification {
    ls_executeOnMonitorQueue(^{
        for (id<LSMonitorModule> module in self.monitorManager.monitorModules) {
            if ([module respondsToSelector:@selector(applicationWillResignActive)]) {
                [module applicationWillResignActive];
            }
        }
    }, NO);
    
    ls_executeOnDataProcessQueue(^{
        for (id<LSDataProcessor> processor in self.processManager.currentProcessors) {
            if ([processor respondsToSelector:@selector(applicationWillResignActive)]) {
                [processor applicationWillResignActive];
            }
        }
    }, NO);
}

- (void)applicationDidBecomeActiveNotification:(__unused NSNotification *)notification {
    ls_executeOnMonitorQueue(^{
        for (id<LSMonitorModule> module in self.monitorManager.monitorModules) {
            if ([module respondsToSelector:@selector(applicationDidBecomeActive)]) {
                [module applicationDidBecomeActive];
            }
        }
    }, NO);
    
    ls_executeOnDataProcessQueue(^{
        for (id<LSDataProcessor> processor in self.processManager.currentProcessors) {
            if ([processor respondsToSelector:@selector(applicationDidBecomeActive)]) {
                [processor applicationDidBecomeActive];
            }
        }
    }, NO);
}

#pragma mark - Getter

- (LSMonitorManager *)monitorManager {
    if (!_monitorManager) {
        _monitorManager = [[LSMonitorManager alloc] init];
        _monitorManager.apm = self;
    }
    return _monitorManager;
}

- (LSDataProcessManager *)processManager {
    if (!_processManager) {
        _processManager = [[LSDataProcessManager alloc] init];
        _processManager.apm = self;
    }
    return _processManager;
}

@end
