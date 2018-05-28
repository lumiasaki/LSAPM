//
//  LSUtils.h
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/12.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSDataProcessor.h"

FOUNDATION_EXPORT dispatch_queue_t LSGetMonitorManagerQueue();
FOUNDATION_EXPORT BOOL LSIsMonitorManagerQueue();

FOUNDATION_EXPORT dispatch_queue_t LSGetDataProcessManagerQueue();
FOUNDATION_EXPORT BOOL LSIsDataProcessManagerQueue();

FOUNDATION_EXPORT void ls_executeOnMonitorQueue(dispatch_block_t task, BOOL sync);
FOUNDATION_EXPORT void ls_executeOnDataProcessQueue(dispatch_block_t task, BOOL sync);

FOUNDATION_EXPORT BOOL ls_versionIsGreaterThanOrEqualTo(double targetVersion);

@interface LSUtils : NSObject

+ (void)asyncExecute:(dispatch_block_t)task onQueue:(dispatch_queue_t)queue withGroup:(dispatch_group_t)group autoLeave:(BOOL)leave;

@end

@interface LSUtils(LSSwizzling)

+ (void)swizzleClassMethods:(Class)class originalSelector:(SEL)origSel swizzledSelector:(SEL)swizSel;
+ (void)swizzleInstanceMethods:(Class)class originalSelector:(SEL)origSel swizzledSelector:(SEL)swizSel;

@end
