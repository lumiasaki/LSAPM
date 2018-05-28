//
//  LSANRRecorder.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/14.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSANRRecorder : NSThread

- (instancetype)initWithThreshold:(double)threshold blockHandler:(void(^)(void))handler NS_DESIGNATED_INITIALIZER;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@end
