//
//  LSDeviceInfoRecorder.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/7.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LSDeviceInfoRecorder : NSObject

//设备
+ (NSString *)deviceType;

//系统
+ (NSString *)OSVersion;

//屏幕亮度
+ (CGFloat)screenBrightness;

//是否插入数据线
+ (BOOL)deviceIsPluggedIn;

//是否破解
+ (BOOL)isJailbreak;

//电量
+ (float)batteryLevel;

//运营商
+ (NSString *)carrier;

//2G／3G／WIFI
+ (NSString *)networkType;

//+ (NSInteger)signalStrength;

@end
