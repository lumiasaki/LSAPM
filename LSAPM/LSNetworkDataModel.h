//
//  LSNetworkDataModel.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/26.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSDictionaryConvertable.h"

@interface LSNetworkDataModelBuilder : NSObject

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *httpMethod;
@property (nonatomic, strong) NSString *httpStatusCode;
@property (nonatomic, strong) NSString *errorMsg;
@property (nonatomic, assign) NSUInteger requestSize;
@property (nonatomic, assign) NSUInteger responseSize;
@property (nonatomic, strong) NSDictionary *requestHeaderFields;

@property (nonatomic, strong) NSString *networkProtocolName;

@property (nonatomic, strong) NSNumber *proxyConnection;
@property (nonatomic, strong) NSNumber *reusedConnection;
@property (nonatomic, assign) NSURLSessionTaskMetricsResourceFetchType resoucesType;

@property (nonatomic, strong) NSDate *fetchStart;
@property (nonatomic, strong) NSDate *dnsLookupStart;
@property (nonatomic, strong) NSDate *dnsLookupEnd;
@property (nonatomic, strong) NSDate *connectStart;
@property (nonatomic, strong) NSDate *connectEnd;
@property (nonatomic, strong) NSDate *sslConnectionStart;
@property (nonatomic, strong) NSDate *sslConnectionEnd;
@property (nonatomic, strong) NSDate *requestStart;
@property (nonatomic, strong) NSDate *requestEnd;
@property (nonatomic, strong) NSDate *responseStart;
@property (nonatomic, strong) NSDate *responseEnd;

@end

@interface LSNetworkDataModel : NSObject<LSDictionaryConvertable, NSCoding>

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSString *httpMethod;
@property (nonatomic, strong, readonly) NSString *httpStatusCode;
@property (nonatomic, strong, readonly) NSString *errorMsg;
@property (nonatomic, assign, readonly) NSUInteger requestSize;
@property (nonatomic, assign, readonly) NSUInteger responseSize;
@property (nonatomic, strong, readonly) NSDictionary *requestHeaderFields;

@property (nonatomic, strong, readonly) NSString *networkProtocolName;

@property (nonatomic, strong, readonly) NSNumber *proxyConnection;
@property (nonatomic, strong, readonly) NSNumber *reusedConnection;
@property (nonatomic, assign, readonly) NSURLSessionTaskMetricsResourceFetchType resoucesType;

@property (nonatomic, strong, readonly) NSDate *fetchStart;
@property (nonatomic, strong, readonly) NSDate *dnsLookupStart;
@property (nonatomic, strong, readonly) NSDate *dnsLookupEnd;
@property (nonatomic, strong, readonly) NSDate *connectStart;
@property (nonatomic, strong, readonly) NSDate *connectEnd;
@property (nonatomic, strong, readonly) NSDate *sslConnectionStart;
@property (nonatomic, strong, readonly) NSDate *sslConnectionEnd;
@property (nonatomic, strong, readonly) NSDate *requestStart;
@property (nonatomic, strong, readonly) NSDate *requestEnd;
@property (nonatomic, strong, readonly) NSDate *responseStart;
@property (nonatomic, strong, readonly) NSDate *responseEnd;

- (instancetype)initWithBuilder:(void(^)(LSNetworkDataModelBuilder *))builder;

@end
