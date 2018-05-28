//
//  LSNetworkDataModel.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/26.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSNetworkDataModel.h"
#import "NSMutableDictionary+LSSafeAdd.h"

@interface LSNetworkDataModel ()

@property (nonatomic, strong, readwrite) NSURL *url;
@property (nonatomic, strong, readwrite) NSString *httpMethod;
@property (nonatomic, strong, readwrite) NSString *httpStatusCode;
@property (nonatomic, strong, readwrite) NSString *errorMsg;
@property (nonatomic, assign, readwrite) NSUInteger requestSize;
@property (nonatomic, assign, readwrite) NSUInteger responseSize;
@property (nonatomic, strong, readwrite) NSDictionary *requestHeaderFields;

@property (nonatomic, strong, readwrite) NSString *networkProtocolName;

@property (nonatomic, strong, readwrite) NSNumber *proxyConnection;
@property (nonatomic, strong, readwrite) NSNumber *reusedConnection;
@property (nonatomic, assign, readwrite) NSURLSessionTaskMetricsResourceFetchType resoucesType;

@property (nonatomic, strong, readwrite) NSDate *fetchStart;
@property (nonatomic, strong, readwrite) NSDate *dnsLookupStart;
@property (nonatomic, strong, readwrite) NSDate *dnsLookupEnd;
@property (nonatomic, strong, readwrite) NSDate *connectStart;
@property (nonatomic, strong, readwrite) NSDate *connectEnd;
@property (nonatomic, strong, readwrite) NSDate *sslConnectionStart;
@property (nonatomic, strong, readwrite) NSDate *sslConnectionEnd;
@property (nonatomic, strong, readwrite) NSDate *requestStart;
@property (nonatomic, strong, readwrite) NSDate *requestEnd;
@property (nonatomic, strong, readwrite) NSDate *responseStart;
@property (nonatomic, strong, readwrite) NSDate *responseEnd;

@end
@implementation LSNetworkDataModel

- (instancetype)initWithBuilder:(void (^)(LSNetworkDataModelBuilder *))builder {
    if (self = [super init]) {
        LSNetworkDataModelBuilder *b = [[LSNetworkDataModelBuilder alloc] init];
        builder(b);
        
        _url = b.url;
        _httpMethod = b.httpMethod;
        _httpStatusCode = b.httpStatusCode;
        _errorMsg = b.errorMsg;
        _requestSize = b.requestSize;
        _responseSize = b.responseSize;
        _requestHeaderFields = b.requestHeaderFields;
        _networkProtocolName = b.networkProtocolName;
        _fetchStart = b.fetchStart;
        _dnsLookupStart = b.dnsLookupStart;
        _dnsLookupEnd = b.dnsLookupEnd;
        _connectStart = b.connectStart;
        _connectEnd = b.connectEnd;
        _sslConnectionStart = b.sslConnectionStart;
        _sslConnectionEnd = b.sslConnectionEnd;
        _requestStart = b.responseStart;
        _requestEnd = b.requestEnd;
        _responseStart = b.responseStart;
        _responseEnd = b.responseEnd;
        
        _proxyConnection = b.proxyConnection;
        _reusedConnection = b.reusedConnection;
        _resoucesType = b.resoucesType;
    }
    
    return self;
}

#pragma mark - LSDictionaryConvertable

- (instancetype)instanceWithData:(NSDictionary *)dict {
    if (![dict isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    LSNetworkDataModel *model = [[LSNetworkDataModel alloc] init];
    
    model.url = dict[@"url"];
    model.httpMethod = dict[@"httpMethod"];
    model.httpStatusCode = dict[@"httpStatusCode"];
    model.errorMsg = dict[@"errorMsg"];
    model.requestSize = [dict[@"requestSize"] unsignedIntegerValue];
    model.responseSize = [dict[@"responseSize"] unsignedIntegerValue];
    model.requestHeaderFields = dict[@"requestHeaderFields"];
    
    model.networkProtocolName = dict[@"networkProtocolName"];
    model.proxyConnection = dict[@"proxyConnection"];
    model.reusedConnection = dict[@"reusedConnection"];
    model.resoucesType = [dict[@"resoucesType"] integerValue];
    
    model.fetchStart = dict[@"fetchStart"];
    model.dnsLookupStart = dict[@"dnsLookupStart"];
    model.dnsLookupEnd = dict[@"dnsLookupEnd"];
    model.connectStart = dict[@"connectStart"];
    model.connectEnd = dict[@"connectEnd"];
    model.sslConnectionStart = dict[@"sslConnectionStart"];
    model.sslConnectionEnd = dict[@"sslConnectionEnd"];
    model.requestStart = dict[@"requestStart"];
    model.requestEnd = dict[@"requestEnd"];
    model.responseStart = dict[@"responseStart"];
    model.responseEnd = dict[@"responseEnd"];
    
    return model;
}

- (NSDictionary *)convertedData {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    [result ls_safeAddObject:self.url key:@"url"];
    [result ls_safeAddObject:self.httpMethod key:@"httpMethod"];
    [result ls_safeAddObject:self.httpStatusCode key:@"httpStatusCode"];
    [result ls_safeAddObject:self.errorMsg key:@"errorMsg"];
    [result ls_safeAddObject:@(self.requestSize) key:@"requestSize"];
    [result ls_safeAddObject:@(self.responseSize) key:@"responseSize"];
    [result ls_safeAddObject:self.requestHeaderFields key:@"requestHeaderFields"];
    
    [result ls_safeAddObject:self.networkProtocolName key:@"networkProtocolName"];
    [result ls_safeAddObject:self.proxyConnection key:@"proxyConnection"];
    [result ls_safeAddObject:self.reusedConnection key:@"reusedConnection"];
    [result ls_safeAddObject:@(self.resoucesType) key:@"resoucesType"];
    
    [result ls_safeAddObject:self.fetchStart key:@"fetchStart"];
    [result ls_safeAddObject:self.dnsLookupStart key:@"dnsLookupStart"];
    [result ls_safeAddObject:self.dnsLookupEnd key:@"dnsLookupEnd"];
    [result ls_safeAddObject:self.connectStart key:@"connectStart"];
    [result ls_safeAddObject:self.connectEnd key:@"connectEnd"];
    [result ls_safeAddObject:self.sslConnectionStart key:@"sslConnectionStart"];
    [result ls_safeAddObject:self.sslConnectionEnd key:@"sslConnectionEnd"];
    [result ls_safeAddObject:self.requestStart key:@"requestStart"];
    [result ls_safeAddObject:self.requestEnd key:@"requestEnd"];
    [result ls_safeAddObject:self.responseStart key:@"responseStart"];
    [result ls_safeAddObject:self.responseEnd key:@"responseEnd"];
    
    return result.copy;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
#define e(x) \
[aCoder encodeObject:self.x forKey:@#x];
    
    e(url)
    e(httpMethod)
    e(httpStatusCode)
    e(errorMsg)
    
    [aCoder encodeObject:@(self.requestSize) forKey:@"requestSize"];
    [aCoder encodeObject:@(self.responseSize) forKey:@"responseSize"];
    
    e(requestHeaderFields)
    e(networkProtocolName)
    e(proxyConnection)
    e(reusedConnection)
    
    [aCoder encodeInteger:self.resoucesType forKey:@"resoucesType"];
    
    e(fetchStart)
    e(dnsLookupStart)
    e(dnsLookupEnd)
    e(connectStart)
    e(connectEnd)
    e(sslConnectionStart)
    e(sslConnectionEnd)
    e(requestStart)
    e(requestEnd)
    e(responseStart)
    e(responseEnd)
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
#define d(x) \
_##x = [aDecoder decodeObjectForKey:@#x];
    
    if (self = [super init]) {
        d(url)
        d(httpMethod)
        d(httpStatusCode)
        d(errorMsg)
        
        _requestSize = [[aDecoder decodeObjectForKey:@"requestSize"] unsignedIntegerValue];
        _responseSize = [[aDecoder decodeObjectForKey:@"responseSize"] unsignedIntegerValue];
        
        d(requestHeaderFields)
        d(networkProtocolName)
        d(proxyConnection)
        d(reusedConnection)
        
        _resoucesType = [aDecoder decodeIntegerForKey:@"resoucesType"];
        
        d(fetchStart)
        d(dnsLookupStart)
        d(dnsLookupEnd)
        d(connectStart)
        d(connectEnd)
        d(sslConnectionStart)
        d(sslConnectionEnd)
        d(requestStart)
        d(requestEnd)
        d(responseStart)
        d(responseEnd)
    }
    
    return self;
}

@end

@implementation LSNetworkDataModelBuilder

@end
