//
//  LSNetworkBasicRecordModel.m
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/24.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSNetworkBasicRecordModel.h"
#import <objc/runtime.h>

@implementation LSNetworkBasicRecordModel

@end

@implementation LSNetworkBasicRecordModel (Metrics)

#define PROPERTY_SETTER_GETTER_TYPE(setter, getter, type) \
- (void)setter:(type)value { \
objc_setAssociatedObject(self, @selector(getter), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
} \
\
- (type)getter { \
return objc_getAssociatedObject(self, _cmd); \
} \

PROPERTY_SETTER_GETTER_TYPE(setMetrics, metrics, NSURLSessionTaskMetrics *)

@end
