//
//  LSViewControllerTransitionTraceModule.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/27.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSViewControllerTransitionTraceModule.h"
#import "LSViewControllerTransitionTraceDataModel.h"
#import "LSMonitorManager.h"
#import "LSViewControllerTransitionInfoImplement.h"
#import "LSViewControllerTransitionInfoResponseType.h"

// TODO: 暂时取消注册
//LSMonitor(LSViewControllerTransitionTraceModule)

@implementation LSViewControllerTransitionTraceModule

@synthesize monitorManager = _monitorManager;

+ (NSString *)moduleIdentifier {
    return kLSViewControllerTransitionTraceModuleIdentifier;
}

+ (Class)dataModelClass {
    return LSViewControllerTransitionTraceDataModel.class;
}

- (void)start {
    // if caller not assign a custom transition info provider, the module will use default LSViewControllerTransitionInfoImplement class to get infomation via an associated UINavigationController
    if (!self.transitionInfoProvider && self.navigationControllerForDefaultProviderSetupBlock) {
        self.transitionInfoProvider = [[LSViewControllerTransitionInfoImplement alloc] init];
        
        self.navigationControllerForDefaultProviderSetupBlock(self.transitionInfoProvider);
    }
}

- (void)stop {
    self.transitionInfoProvider = nil;
}

- (void)responseForMessage:(NSDictionary *)msg response:(void (^)(id))response {
    if (!response) {
        return;
    }
    
    NSInteger requestType = [msg[LS_MODULE_SECTION_REQUEST_TYPE] integerValue];
    
    switch (requestType) {
        case GetViewControllerTrace:
        {
            NSString *trace = [self.transitionInfoProvider viewControllerTransitionInfo];
            NSString *visibleVCName = [self.transitionInfoProvider visibleViewControllerName];
            
            LSViewControllerTransitionTraceDataModel *model = [[LSViewControllerTransitionTraceDataModel alloc] initWithBuilder:^(LSViewControllerTransitionTraceDataBuilder *b) {
                b.viewControllerTrace = trace;
                b.visibleViewControllerName = visibleVCName;
            }];
            
            response(model);
            
            break;
        }
        default:
            response(nil);
            break;
    }
}

@end
