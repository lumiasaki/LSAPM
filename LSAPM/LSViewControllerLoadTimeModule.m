//
//  LSViewControllerLoadTimeModule.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/18.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSViewControllerLoadTimeModule.h"
#import "UIViewController+LSRenderer.h"
#import "LSMonitorManager.h"

// TODO: 确认是否qav已经做了，暂时不注册
//LSMonitor(LSViewControllerLoadTimeModule)

@implementation LSViewControllerLoadTimeModule

@synthesize monitorManager = _monitorManager;

+ (NSString *)moduleIdentifier {
    return kLSViewControllerLoadTimeMonitorIdentifier;
}

+ (Class)dataModelClass {
    return LSRendererDataModel.class;
}

- (void)start {
    // TODO: 可否通过统一在worker queue上确保线程安全？
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIViewController setLs_viewControllerLoadMonitorModule:self];
        [UIViewController ls_startMonitoring];
    });
}

- (void)stop {
    // TODO: 可否通过统一在worker queue上确保线程安全？
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIViewController ls_invalidate];
    });
}

- (void)record:(LSViewControllerRecordModel *)recordModel {
    LSDataPassToProcessorModel *data = [LSDataPassToProcessorModel new];
    
    data.canResponse = @[kLSLoggerProcessorIdentifier];
    //TODO: 处理剩下逻辑
//    data.data = @{@"viewController": recordModel.viewController,
//                  @"method": recordModel.methodName,
//                  @"timestamp": @(recordModel.timestamp),
//                  };
    
    data.eventName = kLSEventNameViewControllerLoadTime;
    
    [self.monitorManager sendUnifiedDataToDataProcessor:data];
}

- (void)responseForMessage:(NSDictionary *)msg response:(void (^)(id))response {}

@end
