//
//  LSURLConnectionMITM.m
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/24.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSURLConnectionMITM.h"
#import "LSNetworkModule.h"
#import "LSNetworkBasicRecordModel.h"

@interface LSURLConnectionMITM ()

@property (nonatomic, strong, readwrite) id target;
@property (nonatomic, strong) LSNetworkBasicRecordModel *model;

@property (nonatomic, assign) NSUInteger dataSize;

@end
@implementation LSURLConnectionMITM

- (instancetype)initWithTarget:(id)target {
    if (self = [super init]) {
        _target = target;
        _dataSize = 0;
        _model = [[LSNetworkBasicRecordModel alloc] init];
    }
    
    return self;
}

#pragma mark - NSURLConnection Delegate

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    if ([self.target respondsToSelector:_cmd]) {
        return [self.target connectionShouldUseCredentialStorage:connection];
    }
    
    return NO;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    self.model.startTime = [NSDate date];
    
    if ([self.target respondsToSelector:_cmd]) {
        [self.target connection:connection willSendRequestForAuthenticationChallenge:challenge];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    if ([self.target respondsToSelector:_cmd]) {
        return [self.target connection:connection canAuthenticateAgainstProtectionSpace:protectionSpace];
    }
    
    return NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([self.target respondsToSelector:_cmd]) {
        [self.target connection:connection didReceiveAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([self.target respondsToSelector:_cmd]) {
        [self.target connection:connection didCancelAuthenticationChallenge:challenge];
    }
}

#pragma clang diagnostic pop

- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response {
    self.model.startTime = [NSDate date];
    
    if ([self.target respondsToSelector:_cmd]) {
        return [self.target connection:connection willSendRequest:request redirectResponse:response];
    }
    
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.model.response = response.copy;
    
    if ([self.target respondsToSelector:_cmd]) {
        [self.target connection:connection didReceiveResponse:response];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    _dataSize += [data length];
    
    if ([self.target respondsToSelector:_cmd]) {
        [self.target connection:connection didReceiveData:data];
    }
}

- (nullable NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request {
    if ([self.target respondsToSelector:_cmd]) {
        return [self.target connection:connection needNewBodyStream:request];
    }
    
    return nil;
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if ([self.target respondsToSelector:_cmd]) {
        [self.target connection:connection
                didSendBodyData:bytesWritten
              totalBytesWritten:totalBytesWritten
      totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

- (nullable NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    if ([self.target respondsToSelector:_cmd]) {
        return [self.target connection:connection willCacheResponse:cachedResponse];
    }
    
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.model.endTime = [NSDate date];
    self.model.responseSize = _dataSize;
    self.model.request = connection.originalRequest.copy;
    
    [self.module record:self.model];
    
    if ([self.target respondsToSelector:_cmd]) {
        [self.target connectionDidFinishLoading:connection];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {    
    self.model.error = error;
    self.model.endTime = self.model.endTime ? : [NSDate date];
    self.model.connectionEstablishedTime = self.model.connectionEstablishedTime ? : self.model.endTime;
    
    [self.module record:self.model];
    
    if ([self.target respondsToSelector:_cmd]) {
        [self.target connection:connection didFailWithError:error];
    }
}

#pragma mark - NSURLConnectionDownloadDelegate

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes {
    _dataSize += bytesWritten;
    
    if ([self.target respondsToSelector:_cmd]) {
        [self.target connection:connection didWriteData:bytesWritten totalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
    }
}

- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes {
    if ([self.target respondsToSelector:_cmd]) {
        [self.target connectionDidResumeDownloading:connection totalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
    }
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *) destinationURL {
    self.model.endTime = [NSDate date];
    self.model.responseSize = _dataSize;
    
    if ([self.target respondsToSelector:_cmd]) {
        [self.target connectionDidFinishDownloading:connection destinationURL:destinationURL];
    }
}

@end
