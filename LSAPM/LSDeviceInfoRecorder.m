//
//  LSDeviceInfoRecorder.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/7.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSDeviceInfoRecorder.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <sys/utsname.h>
#import <UIKit/UIKit.h>
#import "Reachability.h"

@implementation LSDeviceInfoRecorder

+ (NSString *)deviceType {
    return [NSString stringWithCString:device_info().machine encoding:NSUTF8StringEncoding];
}

+ (NSString *)OSVersion {
    return [UIDevice currentDevice].systemVersion;
}

+ (CGFloat)screenBrightness {
    return [UIScreen mainScreen].brightness;
}

+ (BOOL)deviceIsPluggedIn {
    BOOL preStatus = UIDevice.currentDevice.isBatteryMonitoringEnabled;
    BOOL result = NO;
    
    UIDevice.currentDevice.batteryMonitoringEnabled = YES;
    
    result = UIDevice.currentDevice.batteryState == UIDeviceBatteryStateCharging || UIDevice.currentDevice.batteryState == UIDeviceBatteryStateFull;
    
    UIDevice.currentDevice.batteryMonitoringEnabled = preStatus;
    
    return result;
}

+ (BOOL)isJailbreak {
    return [[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"];
}

+ (float)batteryLevel {
    return [UIDevice currentDevice].batteryLevel;
}

+ (NSString *)networkType
{
    Reachability *curReach = [Reachability reachabilityForInternetConnection];
    
    // 获得网络状态
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
        {
            return nil;
        }
            
        case ReachableViaWWAN:
        {
            // 判断是否能够取得运营商
            Class telephoneNetWorkClass = (NSClassFromString(@"CTTelephonyNetworkInfo"));
            if (telephoneNetWorkClass != nil)
            {
                // TODO: 潜在的线程问题
                static CTTelephonyNetworkInfo * telephonyNetworkInfo = nil;
                if (telephonyNetworkInfo == nil)
                {
                    telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
                }
                
                if ([telephonyNetworkInfo respondsToSelector:@selector(currentRadioAccessTechnology)])
                {
                    // 7.0 系统的适配处理。
                    
                    return [NSString stringWithFormat:@"%@",telephonyNetworkInfo.currentRadioAccessTechnology];
                }
            }
            
            return @"2g/3g";
        }
            
        case ReachableViaWiFi:
        {
            return @"wifi";
        }
            
        default:
            break;
    }
    
    return nil;
}

+ (NSString *)carrier {
    // 判断是否能够取得运营商
    if (NSClassFromString(@"CTTelephonyNetworkInfo")) {
        // TODO: 潜在的线程问题
        static CTTelephonyNetworkInfo *telephonyNetworkInfo = nil;
        // TestFlight SDK某一版本对CTTelephonyNetworkInfo有Bug
        if (telephonyNetworkInfo == nil) {
            telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
        }
        
        // 获得运营商的信息
        if (NSClassFromString(@"CTCarrier")) {
            CTCarrier *carrier = telephonyNetworkInfo.subscriberCellularProvider;
            
            // 移动运营商的mcc 和 mnc
            NSString * mobileCountryCode = [carrier mobileCountryCode];
            NSString * mobileNetworkCode = [carrier mobileNetworkCode];
            
            // 统计能够取到信息的运营商
            if ((mobileCountryCode != nil) && (mobileNetworkCode != nil)) {
                return [[NSString alloc] initWithFormat:@"%@%@", mobileCountryCode, mobileNetworkCode];
            }
        }
    }
    
    return nil;
}

//+ (NSInteger)signalStrength {
//    NSArray *subviews = [[[UIApplication.sharedApplication valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
//    
//    id networkItemView = nil;
//    
//    for (id subview in subviews) {
//        if ([subviews isKindOfClass:NSClassFromString(@"UIStatusBarSignalStrengthItemView")]) {
//            networkItemView = subview;
//            
//            break;
//        }
//    }
//    
//    return [[networkItemView valueForKey:@"signalStrengthRaw"] integerValue];
//}

#pragma mark - Internal Functions

typedef struct utsname utsname_t;

static inline utsname_t device_info() {
    utsname_t device_info;
    
    uname(&device_info);
    
    return device_info;
}

@end
