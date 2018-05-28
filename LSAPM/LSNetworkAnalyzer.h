//
//  LSNetworkAnalyzer.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/26.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSNetworkBasicRecordModel.h"
#import "LSNetworkDataModel.h"

@protocol LSNetworkAnalyzer <NSObject>

@required
// because the network module will keep a strong reference to network analyzer instance, this method should be pure function strongly recommend,
// this method is designed as an instance method just for more flexablility
- (LSNetworkDataModel *)analyseRecording:(LSNetworkBasicRecordModel *)raw;

@end
