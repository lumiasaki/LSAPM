//
//  LSUtils.m
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/12.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSUtils.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation LSUtils

#pragma mark - Public

BOOL ls_versionIsGreaterThanOrEqualTo(double targetVersion) {
    NSNumber *version = @([[[UIDevice currentDevice] systemVersion] floatValue]);
    
    return [version compare:@(targetVersion)] == NSOrderedDescending || [version compare:@(targetVersion)] == NSOrderedSame;
}

+ (void)asyncExecute:(dispatch_block_t)task onQueue:(dispatch_queue_t)queue withGroup:(dispatch_group_t)group autoLeave:(BOOL)leave {
    assert(task);
    assert(queue);
    assert(group);
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        task();
        
        if (leave) {
            dispatch_group_leave(group);
        }
    });
}


dispatch_queue_t LSGetMonitorManagerQueue() {
    static NSString *const MonitorManagerQueueName = @"com.ls.monitor_manager_queue";
    
    static dispatch_queue_t monitorManagerQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monitorManagerQueue = dispatch_queue_create(MonitorManagerQueueName.UTF8String, DISPATCH_QUEUE_SERIAL);
    });
    
    return monitorManagerQueue;
}

BOOL LSIsMonitorManagerQueue() {
    static void *monitorManagerQueueKey = &monitorManagerQueueKey;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_set_specific(LSGetMonitorManagerQueue(), monitorManagerQueueKey, monitorManagerQueueKey, NULL);
    });
    
    return dispatch_get_specific(monitorManagerQueueKey) == monitorManagerQueueKey;
}

dispatch_queue_t LSGetDataProcessManagerQueue() {
    static NSString *const DataProcessManagerQueueName = @"com.ls.data_process_queue";
    
    static dispatch_queue_t dataProcessManagerQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataProcessManagerQueue = dispatch_queue_create(DataProcessManagerQueueName.UTF8String, DISPATCH_QUEUE_SERIAL);
    });
    
    return dataProcessManagerQueue;
}

BOOL LSIsDataProcessManagerQueue() {
    static void *dataProcessManagerQueueKey = &dataProcessManagerQueueKey;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_set_specific(LSGetDataProcessManagerQueue(), dataProcessManagerQueueKey, dataProcessManagerQueueKey, NULL);
    });
    
    return dispatch_get_specific(dataProcessManagerQueueKey) == dataProcessManagerQueueKey;
}

void ls_executeOnMonitorQueue(dispatch_block_t task, BOOL sync) {
    execute(task, LSGetMonitorManagerQueue(), sync, LSIsMonitorManagerQueue());
}

void ls_executeOnDataProcessQueue(dispatch_block_t task, BOOL sync) {
    execute(task, LSGetDataProcessManagerQueue(), sync, LSIsDataProcessManagerQueue());
}

#pragma mark - Private

static void execute(dispatch_block_t task, dispatch_queue_t queue, BOOL sync, BOOL isOnQueueAlready) {
    if (isOnQueueAlready) {
        task();
    } else if (sync) {
        dispatch_sync(queue, task);
    } else {
        dispatch_async(queue, task);
    }
}

@end

@implementation LSUtils (Swizzling)

+ (void)swizzleClassMethods:(Class)class originalSelector:(SEL)origSel swizzledSelector:(SEL)swizSel {
    Class metaClass = object_getClass(class);
    
    Method origMethod = class_getClassMethod(class, origSel);
    Method swizMethod = class_getClassMethod(class, swizSel);
    
    BOOL didAddMethod = class_addMethod(metaClass, origSel, method_getImplementation(swizMethod), method_getTypeEncoding(swizMethod));
    if (didAddMethod) {
        class_replaceMethod(metaClass, swizSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, swizMethod);
    }
}

+ (void)swizzleInstanceMethods:(Class)class originalSelector:(SEL)origSel swizzledSelector:(SEL)swizSel {
    Method origMethod = class_getInstanceMethod(class, origSel);
    Method swizMethod = class_getInstanceMethod(class, swizSel);
    
    BOOL didAddMethod = class_addMethod(class, origSel, method_getImplementation(swizMethod), method_getTypeEncoding(swizMethod));
    if (didAddMethod) {
        class_replaceMethod(class, swizSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, swizMethod);
    }
}

@end
