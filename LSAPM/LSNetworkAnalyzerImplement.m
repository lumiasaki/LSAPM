//
//  LSNetworkAnalyzerImplement.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/26.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSNetworkAnalyzerImplement.h"
#import "LSNetworkDataModel.h"

@implementation LSNetworkAnalyzerImplement

- (LSNetworkDataModel *)analyseRecording:(LSNetworkBasicRecordModel *)raw {
    LSNetworkDataModel *model = [[LSNetworkDataModel alloc] initWithBuilder:^(LSNetworkDataModelBuilder *b) {
        b.url = extractUrl(raw);
        b.httpMethod = extractHTTPMethod(raw);
        b.httpStatusCode = extractHTTPStatusCode(raw);
        b.errorMsg = extractErrorMsg(raw);
        b.requestSize = extractRequestSize(raw);
        b.responseSize = raw.responseSize;
        b.requestHeaderFields = extractRequestHeaderField(raw);
        
        // TODO: 这个是基于每一个请求都是一个task，没有复用task，需要确认
        if (raw.metrics.transactionMetrics.count > 0 && ls_versionIsGreaterThanOrEqualTo(10)) {
            NSURLSessionTaskTransactionMetrics *metric = raw.metrics.transactionMetrics[0];
            
            b.networkProtocolName = metric.networkProtocolName;
            
            b.fetchStart = metric.fetchStartDate;
            b.dnsLookupStart = metric.domainLookupStartDate;
            b.dnsLookupEnd = metric.domainLookupEndDate;
            b.connectStart = metric.connectStartDate;
            b.connectEnd = metric.connectEndDate;
            b.sslConnectionStart = metric.secureConnectionStartDate;
            b.sslConnectionEnd = metric.secureConnectionEndDate;
            b.requestStart = metric.requestStartDate;
            b.requestEnd = metric.requestEndDate;
            b.responseStart = metric.responseStartDate;
            b.responseEnd = metric.responseEndDate;
            
            b.proxyConnection = @(metric.proxyConnection);
            b.reusedConnection = @(metric.reusedConnection);
            b.resoucesType = metric.resourceFetchType;
            
        } else {
            b.fetchStart = raw.startTime;
            b.connectEnd = raw.connectionEstablishedTime;
            b.responseEnd = raw.endTime;
        }
    }];
    
    return model;
}

static inline NSURL *extractUrl(LSNetworkBasicRecordModel *data) {
    return data.request.URL.copy;
}

static inline NSString *extractHTTPMethod(LSNetworkBasicRecordModel *data) {
    return data.request.HTTPMethod;
}

static inline NSUInteger extractRequestSize(LSNetworkBasicRecordModel *data) {
    return data.request.HTTPBody.length;
}

static inline NSDictionary *extractRequestHeaderField(LSNetworkBasicRecordModel *data) {
    return data.request.allHTTPHeaderFields.copy;
}

static inline NSString *extractHTTPStatusCode(LSNetworkBasicRecordModel *data) {
    if ([data.response isKindOfClass:NSHTTPURLResponse.class]) {
        return [NSString stringWithFormat:@"%ld", (long)[(NSHTTPURLResponse *)data.response statusCode]];
    }
    
    return nil;
}

static inline NSString *extractErrorMsg(LSNetworkBasicRecordModel *data) {
    if (!data.error) {
        return nil;
    }
    
    return data.error.localizedDescription;
}

@end
