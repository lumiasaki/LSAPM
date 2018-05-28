//
//  LSPerformanceResponseType.h
//  LSAPM
//
//  Created by Lumia_Saki on 2017/5/13.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

typedef NS_OPTIONS(NSUInteger, LSPerformanceModuleResponseType) {
    InstantFPS = 1 << 0,
    CurrentAppCPUUsage = 1 << 1,
    AppMemoryUsage = 1 << 2,
    GlobalMemoryUsage = 1 << 3
};
