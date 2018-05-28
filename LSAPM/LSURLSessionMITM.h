//
//  LSURLSessionMITM.h
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/24.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LSNetworkModule;

@interface LSURLSessionMITM : NSObject<NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate, NSURLSessionStreamDelegate>

@property (nonatomic, strong, readonly) id target;
@property (nonatomic, strong) LSNetworkModule *module;

- (instancetype)initWithTarget:(id)target;

@end
