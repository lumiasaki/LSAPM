//
//  NSURLConnection+LSAPM.h
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/24.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LSNetworkModule;

@interface NSURLConnection (LSAPM)

+ (void)setLs_networkMonitorModule:(LSNetworkModule *)module;

// not thread safe, caller guaranteed
+ (void)ls_startMonitoring;
+ (void)ls_invalidate;

@end
