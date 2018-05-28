//
//  LSMonitorModule.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/10.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSBootable.h"
#import "LSAppStateChangedResponsable.h"

@class LSMonitorManager;

@protocol LSMonitorModule <NSObject, LSBootable, LSAppStateChangedResponsable>

@required
@property (nonatomic, weak) LSMonitorManager *monitorManager;

// use reverse dns lookup strongly recommend, should be unique
+ (NSString *)moduleIdentifier;

+ (Class)dataModelClass;

// accroding to msg, return result, like a input/output port, may sync or async
- (void)responseForMessage:(NSDictionary *)msg response:(void(^)(id))response;

@end
