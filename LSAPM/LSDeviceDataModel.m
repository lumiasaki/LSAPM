//
//  LSDeviceDataModel.m
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/24.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSDeviceDataModel.h"
#import "NSMutableDictionary+LSSafeAdd.h"

@interface LSDeviceDataModel ()

@property (nonatomic, strong, readwrite) NSString *deviceType;
@property (nonatomic, strong, readwrite) NSString *OSVersion;
@property (nonatomic, strong, readwrite) NSNumber *screenBrightness;
@property (nonatomic, strong, readwrite) NSNumber *isPluggedIn;
@property (nonatomic, strong, readwrite) NSNumber *isJailbreak;
@property (nonatomic, strong, readwrite) NSNumber *batteryLevel;
@property (nonatomic, strong, readwrite) NSString *carrier;
@property (nonatomic, strong, readwrite) NSString *networkType;

@end

@implementation LSDeviceDataModel

- (instancetype)initWithBuilder:(void (^)(LSDeviceDataModelBuilder *))builder {
    if (self = [super init]) {
        LSDeviceDataModelBuilder *b = [[LSDeviceDataModelBuilder alloc] init];
        builder(b);
        
        _deviceType = b.deviceType;
        _OSVersion = b.OSVersion;
        _screenBrightness = b.screenBrightness;
        _isPluggedIn = b.isPluggedIn;
        _isJailbreak = b.isJailbreak;
        _batteryLevel = b.batteryLevel;
        _carrier = b.carrier;
        _networkType = b.networkType;
    }
    
    return self;
}

#pragma mark - LSDictionaryConvertable

- (instancetype)instanceWithData:(NSDictionary *)dict {
    if (![dict isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    LSDeviceDataModel *model = [[LSDeviceDataModel alloc] init];
    
    if (!model) {
        return nil;
    }
    
    model.deviceType = dict[@"deviceType"];
    model.OSVersion = dict[@"OSVersion"];
    model.screenBrightness = dict[@"screenBrightness"];
    model.isPluggedIn = dict[@"isPluggedIn"];
    model.isJailbreak = dict[@"isJailbreak"];
    model.batteryLevel = dict[@"batteryLevel"];
    model.carrier = dict[@"carrier"];
    model.networkType = dict[@"networkType"];
    
    return model;
}

- (NSDictionary *)convertedData {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    [result ls_safeAddObject:self.deviceType key:@"deviceType"];
    [result ls_safeAddObject:self.OSVersion key:@"OSVersion"];
    [result ls_safeAddObject:self.screenBrightness key:@"screenBrightness"];
    [result ls_safeAddObject:self.isPluggedIn key:@"isPluggedIn"];
    [result ls_safeAddObject:self.isJailbreak key:@"isJailbreak"];
    [result ls_safeAddObject:self.batteryLevel key:@"batteryLevel"];
    [result ls_safeAddObject:self.carrier key:@"carrier"];
    [result ls_safeAddObject:self.networkType key:@"networkType"];
    
    return result.copy;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
#define encode(x) \
[aCoder encodeObject:self.x forKey:@#x]
    
    encode(deviceType);
    encode(OSVersion);
    encode(screenBrightness);
    encode(isPluggedIn);
    encode(isJailbreak);
    encode(batteryLevel);
    encode(carrier);
    encode(networkType);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
#define decode(x) \
_##x = [aDecoder decodeObjectForKey:@#x]
    
    if (self = [super init]) {
        decode(deviceType);
        decode(OSVersion);
        decode(screenBrightness);
        decode(isPluggedIn);
        decode(isJailbreak);
        decode(batteryLevel);
        decode(carrier);
        decode(networkType);
    }
    
    return self;
}

@end

@implementation LSDeviceDataModelBuilder

@end
