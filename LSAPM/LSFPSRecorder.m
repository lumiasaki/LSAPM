//
//  LSFPSRecorder.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/3.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSFPSRecorder.h"
#import "LSUtils.h"

@interface LSFPSRecorder ()
{
    CFTimeInterval _lastTime;
    NSInteger _frameCount;
}

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign, readwrite) LSFPS latestFps;
@property (nonatomic, assign) BOOL enabled;

@end

@implementation LSFPSRecorder

- (void)dealloc {
    [self.displayLink invalidate];
}

- (instancetype)init {
    if (self = [super init]) {
        _lastTime = 0;
        _frameCount = 0;
        _enabled = YES;
    }
    
    return self;
}

#pragma mark - Protocol Methods

- (void)start {
    if (!self.enabled) {
        return;
    }
    
    self.displayLink.paused = NO;
}

- (void)stop {
    if (!self.enabled) {
        return;
    }
    
    self.displayLink.paused = YES;
}

#pragma mark - Private Methods

- (void)frameUpdate:(CADisplayLink *)displayLink {
    _frameCount += 1;
    CFTimeInterval interval = self.displayLink.timestamp - _lastTime;
    
    if (interval < 1) {
        return;
    }
    
    _lastTime = self.displayLink.timestamp;
    
    _latestFps = _frameCount / interval;
    
    _frameCount = 0;
    
    if (self.frameUpdated) {
        self.frameUpdated(@{
                            @"fps": @(_latestFps)
                            });
    }
}

#pragma mark - Getters

- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(frameUpdate:)];
        _displayLink.paused = YES;
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if(ls_versionIsGreaterThanOrEqualTo(10.0)) {
            _displayLink.preferredFramesPerSecond = 60;
        } else {
            _displayLink.frameInterval = 1;
        }
#pragma clang diagnostic pop
        
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _displayLink;
}

@end
