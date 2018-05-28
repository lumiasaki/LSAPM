//
//  QLSDataUploadConfiguration.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/5/23.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "QLSDataUploadConfiguration.h"

@implementation QLSDataUploadConfiguration

- (instancetype)init {
    if (self = [super init]) {
        _fileBufferSize = 5;
    }
    
    return self;
}

@end
