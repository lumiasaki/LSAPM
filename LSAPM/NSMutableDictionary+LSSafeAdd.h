//
//  NSMutableDictionary+LSSafeAdd.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/6/1.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (LSSafeAdd)

- (void)ls_safeAddObject:(id)value key:(NSString *)key;

@end
