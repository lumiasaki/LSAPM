//
//  LSDataPassToProcessorModel.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/19.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LSPerformanceDataModel.h"
#import "LSDeviceDataModel.h"
#import "LSRendererDataModel.h"
#import "LSStacktraceDataModel.h"
#import "LSNetworkDataModel.h"
#import "LSViewControllerTransitionTraceDataModel.h"
// 未完待续

#import "LSDictionaryConvertable.h"

@interface LSDataPassToProcessorModel : NSObject<LSDictionaryConvertable, NSCoding>

@property (nonatomic, strong) NSArray<NSString *> *canResponse;
@property (nonatomic, strong, readonly) NSUUID *uniqueId;
@property (nonatomic, strong) NSDate *timestamp;        // add by apm system automaticlly
@property (nonatomic, strong) NSString *eventName;      // defined in LSMonitorModuleEventName.h

@property (nonatomic, strong) LSPerformanceDataModel *performance;
@property (nonatomic, strong) LSDeviceDataModel *deviceInfo;
@property (nonatomic, strong) LSRendererDataModel *renderer;
@property (nonatomic, strong) LSStacktraceDataModel *stacktrace;
@property (nonatomic, strong) LSNetworkDataModel *network;
@property (nonatomic, strong) LSViewControllerTransitionTraceDataModel *viewControllerTrace;

@end
