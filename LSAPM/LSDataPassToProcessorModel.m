//
//  LSDataPassToProcessorModel.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/19.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSDataPassToProcessorModel.h"
#import "NSMutableDictionary+LSSafeAdd.h"

@interface LSDataPassToProcessorModel ()

@property (nonatomic, strong, readwrite) NSUUID *uniqueId;

@end
@implementation LSDataPassToProcessorModel

- (instancetype)init {
    if (self = [super init]) {
        _uniqueId = [[NSUUID alloc] init];
    }
    
    return self;
}

#pragma mark - LSDictionaryConvertable

- (instancetype)instanceWithData:(NSDictionary *)dict {
    if (![dict isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    LSDataPassToProcessorModel *model = [self init];
    
    if (!model) {
        return nil;
    }
    
    NSArray<NSString *> *canResponse = dict[@"canResponse"];
    NSUUID *uniqueId = dict[@"uniqueId"];
    NSDate *timestamp = dict[@"timestamp"];
    NSString *eventName = dict[@"eventName"];
    
    LSPerformanceDataModel *performance = [[LSPerformanceDataModel alloc] instanceWithData:dict[@"performance"]];
    
    LSDeviceDataModel *deviceInfo = [[LSDeviceDataModel alloc] instanceWithData:dict[@"deviceInfo"]];
    
    LSRendererDataModel *renderer = [[LSRendererDataModel alloc] instanceWithData:dict[@"renderer"]];
    LSStacktraceDataModel *stacktrace = [[LSStacktraceDataModel alloc] instanceWithData:dict[@"stacktrace"]];
    LSNetworkDataModel *network = [[LSNetworkDataModel alloc] instanceWithData:dict[@"network"]];
    LSViewControllerTransitionTraceDataModel *viewControllerTrace = [[LSViewControllerTransitionTraceDataModel alloc] instanceWithData:dict[@"viewControllerTrace"]];
    
    model.canResponse = canResponse;
    model.uniqueId = uniqueId;
    model.timestamp = timestamp;
    model.eventName = eventName;
    model.performance = performance;
    model.deviceInfo = deviceInfo;
    model.renderer = renderer;
    model.stacktrace = stacktrace;
    model.network = network;
    model.viewControllerTrace = viewControllerTrace;
    
    return model;
}

- (NSDictionary *)convertedData {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    [result ls_safeAddObject:self.canResponse key:@"canResponse"];
    [result ls_safeAddObject:self.uniqueId key:@"uniqueId"];
    [result ls_safeAddObject:self.timestamp key:@"timestamp"];
    [result ls_safeAddObject:self.eventName key:@"eventName"];
    
    // convert custom models to dictionaries
    [result ls_safeAddObject:[self.performance convertedData] key:@"performance"];
    [result ls_safeAddObject:[self.deviceInfo convertedData] key:@"deviceInfo"];
    [result ls_safeAddObject:[self.renderer convertedData] key:@"renderer"];
    [result ls_safeAddObject:[self.stacktrace convertedData] key:@"stacktrace"];
    [result ls_safeAddObject:[self.network convertedData] key:@"network"];
    [result ls_safeAddObject:[self.viewControllerTrace convertedData] key:@"viewControllerTrace"];
    
    return result.copy;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
#define encode(x) \
[aCoder encodeObject:self.x forKey:@#x]
    
    encode(canResponse);
    encode(uniqueId);
    encode(timestamp);
    encode(eventName);
    
    encode(performance);
    encode(deviceInfo);
    encode(renderer);
    encode(stacktrace);
    encode(network);
    encode(viewControllerTrace);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
#define decode(x) \
_##x = [aDecoder decodeObjectForKey:@#x]
        
        decode(canResponse);
        decode(uniqueId);
        decode(timestamp);
        decode(eventName);
        
        decode(performance);
        decode(deviceInfo);
        decode(renderer);
        decode(stacktrace);
        decode(network);
        decode(viewControllerTrace);
    }
    
    return self;
}

@end
