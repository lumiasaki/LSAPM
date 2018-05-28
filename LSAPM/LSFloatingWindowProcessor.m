//
//  LSFloatingWindowProcessor.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/28.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSFloatingWindowProcessor.h"
#import "LSFloatingWindow.h"
#import "LSDataProcessManager.h"

#import "LSPerformanceDataModel.h"

LSProcessor(LSFloatingWindowProcessor)

@interface LSFloatingWindowProcessor ()

@property (nonatomic, assign) BOOL enable;

@property (nonatomic, strong) LSFloatingWindow *floatingWindow;

@end

@implementation LSFloatingWindowProcessor

@synthesize processManager = _processManager;

- (instancetype)init {
    if (self = [super init]) {
        _enable = YES;
    }
    
    return self;
}

+ (NSString *)processorIdentifier {
    return kLSFloatingWindowProcessorIdentifier;
}

+ (NSUInteger)priority {
    return LS_PROCESSOR_PRIORITY_Float_Window;
}

- (BOOL)responseSwitch {
    return YES;
}

- (void)start {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.enable = YES;
        
        NSAssert(self.floatingWindowSuperview, @"should assign superview of floating window before invoke start method");
        
        CGRect originalFrame = self.floatingWindow.frame;
        
        originalFrame.origin.x = 40;
        originalFrame.origin.y = 40;
        
        self.floatingWindow.frame = originalFrame;
        
        [self.floatingWindowSuperview addSubview:self.floatingWindow];
    });
}

- (void)stop {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.enable = NO;
        
        [self.floatingWindow removeFromSuperview];
        self.floatingWindow = nil;
    });
}

- (void)process:(LSDataPassToProcessorModel *)original {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.enable) {
            return;
        }
        
        self.floatingWindow.cpu = original.performance.currentAppCpu;
        self.floatingWindow.memory = original.performance.appMemoryUsage;
        self.floatingWindow.fps = original.performance.instantFps;
        
        if ([original.eventName isEqualToString:kLSEventNameAnr]) {
            [self handleAnrOccurred:original];
        }
    });
}

#pragma mark - Private

- (void)handleAnrOccurred:(LSDataPassToProcessorModel *)data {
    [self.floatingWindow anrOccurred:data.stacktrace.stacktrace];
}

#pragma mark - Getter

- (LSFloatingWindow *)floatingWindow {
    if (!_floatingWindow) {
        _floatingWindow = [[LSFloatingWindow alloc] init];
    }
    
    return _floatingWindow;
}

@end
