//
//  LSDeviceDataModel.h
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/24.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSDictionaryConvertable.h"

@interface LSDeviceDataModelBuilder : NSObject

@property (nonatomic, strong) NSString *deviceType;
@property (nonatomic, strong) NSString *OSVersion;
@property (nonatomic, strong) NSNumber *screenBrightness;
@property (nonatomic, strong) NSNumber *isPluggedIn;
@property (nonatomic, strong) NSNumber *isJailbreak;
@property (nonatomic, strong) NSNumber *batteryLevel;
@property (nonatomic, strong) NSString *carrier;
@property (nonatomic, strong) NSString *networkType;

@end

@interface LSDeviceDataModel : NSObject<LSDictionaryConvertable, NSCoding>

@property (nonatomic, strong, readonly) NSString *deviceType;
@property (nonatomic, strong, readonly) NSString *OSVersion;
@property (nonatomic, strong, readonly) NSNumber *screenBrightness;
@property (nonatomic, strong, readonly) NSNumber *isPluggedIn;
@property (nonatomic, strong, readonly) NSNumber *isJailbreak;
@property (nonatomic, strong, readonly) NSNumber *batteryLevel;
@property (nonatomic, strong, readonly) NSString *carrier;
@property (nonatomic, strong, readonly) NSString *networkType;

- (instancetype)initWithBuilder:(void(^)(LSDeviceDataModelBuilder *))builder;

@end
