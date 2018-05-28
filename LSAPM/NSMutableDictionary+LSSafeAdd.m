//
//  NSMutableDictionary+LSSafeAdd.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/6/1.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "NSMutableDictionary+LSSafeAdd.h"

@implementation NSMutableDictionary (LSSafeAdd)

- (void)ls_safeAddObject:(id)value key:(NSString *)key {
    if (!value || !key) {
        return;
    }
    
    [self setObject:value forKey:key];
}

@end
