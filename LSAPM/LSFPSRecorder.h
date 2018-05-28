//
//  LSFPSRecorder.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/3.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LSMonitorModule.h"

typedef double LSFPS;

@interface LSFPSRecorder : NSObject

@property (nonatomic, copy) void(^frameUpdated)(NSDictionary *);
@property (nonatomic, assign, readonly) LSFPS latestFps;

- (void)start;
- (void)stop;

@end
