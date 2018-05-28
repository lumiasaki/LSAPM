//
//  LSViewControllerTransitionTraceModule.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/27.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSMonitorModule.h"
#import "LSViewControllerTransitionInfoProvider.h"
#import "LSViewControllerTransitionInfoImplement.h"

@interface LSViewControllerTransitionTraceModule : NSObject<LSMonitorModule>

@property (nonatomic, strong) id<LSViewControllerTransitionInfoProvider> transitionInfoProvider;

@property (nonatomic, copy) void(^navigationControllerForDefaultProviderSetupBlock)(LSViewControllerTransitionInfoImplement *defaultProvider);

@end
