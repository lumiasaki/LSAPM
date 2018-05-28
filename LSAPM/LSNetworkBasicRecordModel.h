//
//  LSNetworkBasicRecordModel.h
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/24.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSNetworkBasicRecordModel : NSObject

@property (nonatomic, assign) NSUInteger requestSize;
@property (nonatomic, assign) NSUInteger responseSize;
@property (nonatomic, copy) NSURLRequest *request;
@property (nonatomic, copy) NSURLResponse *response;
@property (nonatomic, copy) NSError *error;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, strong) NSDate *connectionEstablishedTime;

@end

// NSURLSession on iOS10 only
@interface LSNetworkBasicRecordModel (Metrics)

@property (nonatomic, strong) NSURLSessionTaskMetrics *metrics;

@end
