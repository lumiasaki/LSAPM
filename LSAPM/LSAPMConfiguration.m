//
//  LSAPMConfiguration.m
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/12.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSAPMConfiguration.h"
#import "LSPersistenceConfiguration.h"
#import <objc/runtime.h>

@implementation LSAPMConfiguration

- (instancetype)init {
    if (self = [super init]) {
        _env = Debug;
        _persistenceConfiguration = [[LSPersistenceConfiguration alloc] init];
    }
    
    return self;
}

@end

@implementation LSAPMConfiguration (FloatingWindow)

- (void)setFloatingWindowSuperview:(UIView *)floatingWindowSuperview {
    objc_setAssociatedObject(self, @selector(floatingWindowSuperview), floatingWindowSuperview, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)floatingWindowSuperview {
    return objc_getAssociatedObject(self, _cmd);
}

@end
