//
//  LSPersistenceConfiguration.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/5/18.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSPersistenceConfiguration.h"

@implementation LSPersistenceConfiguration

- (instancetype)init {
    if (self = [super init]) {
        _persistenceStrategy = DataItemCount;
    }
    
    return self;
}

@end
