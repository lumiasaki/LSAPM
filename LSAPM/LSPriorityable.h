//
//  LSPriorityable.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/14.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LSPriorityable <NSObject>

@required
/**
 * lower value is priority higher
 */
+ (NSUInteger)priority;

@end
