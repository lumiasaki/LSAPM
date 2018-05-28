//
//  LSANRRecorder.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/14.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSANRRecorder.h"

@interface LSANRRecorder ()
{
    dispatch_semaphore_t _semaphore;
}
@property (nonatomic, assign) BOOL mainThreadBlocked;
@property (nonatomic, assign) double threshold;
@property (nonatomic, copy) void(^handler)(void);

@end

@implementation LSANRRecorder

- (instancetype)initWithThreshold:(double)threshold blockHandler:(void(^)(void))handler {
    if (self = [super init]) {
        _mainThreadBlocked = YES;
        _threshold = threshold;
        _handler = handler;
        _semaphore = dispatch_semaphore_create(0);
    }
    
    return self;
}

#pragma mark - Override

- (void)main {
    while (!self.cancelled) {
        self.mainThreadBlocked = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mainThreadBlocked = NO;
            dispatch_semaphore_signal(_semaphore);
        });
        
        [NSThread sleepForTimeInterval:self.threshold];
        
        if (self.mainThreadBlocked && self.handler) {
            self.handler();
        }
        
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    }
}

@end
