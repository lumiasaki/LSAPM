//
//  LSURLSessionMITM.m
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/24.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSURLSessionMITM.h"
#import "LSURLSessionTaskAgent.h"
#import "LSNetworkBasicRecordModel.h"
#import "LSNetworkModule.h"

@implementation LSURLSessionMITM

- (instancetype)initWithTarget:(id)target {
    if (self = [super init]) {
        _target = target;
    }
    
    return self;
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
    if ([self.target respondsToSelector:_cmd]) {
        [self.target URLSession:session didBecomeInvalidWithError:error];
    }
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    if ([self.target respondsToSelector:_cmd]) {
        [self.target URLSession:session didReceiveChallenge:challenge completionHandler:completionHandler];
    } else {
        // Default handling
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, NULL);
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    if ([self.target respondsToSelector:_cmd]) {
        [self.target URLSessionDidFinishEventsForBackgroundURLSession:session];
    }
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    if ([self.target respondsToSelector:_cmd]) {
        [self.target URLSession:session task:task willPerformHTTPRedirection:response newRequest:request completionHandler:completionHandler];
    } else {
        completionHandler(request);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    if ([self.target respondsToSelector:_cmd]) {
        [self.target URLSession:session task:task didReceiveChallenge:challenge completionHandler:completionHandler];
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream * _Nullable bodyStream))completionHandler {
    if ([self.target respondsToSelector:_cmd]) {
        [self.target URLSession:session task:task needNewBodyStream:completionHandler];
    } else {
        NSInputStream* inputStream = nil;
        
        if (task.originalRequest.HTTPBodyStream &&
            [task.originalRequest.HTTPBodyStream conformsToProtocol:@protocol(NSCopying)])
        {
            inputStream = [task.originalRequest.HTTPBodyStream copy];
        }
        
        completionHandler(inputStream);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    if ([self.target respondsToSelector:_cmd]) {
        [self.target URLSession:session task:task didSendBodyData:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    LSURLSessionTaskAgent *agent = [LSURLSessionTaskAgent agentForTask:task];
    if (agent) {
        agent.model.error = error;
        agent.model.endTime = [NSDate date];
        
        [self.module record:agent.model];
        [LSURLSessionTaskAgent removeAgentForTask:task];
    }
    
    if ([self.target respondsToSelector:_cmd]) {
        [self.target URLSession:session task:task didCompleteWithError:error];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics {
    LSURLSessionTaskAgent *agent = [LSURLSessionTaskAgent agentForTask:task];
    if (agent) {
        agent.model.metrics = metrics;
    }
    
    if ([self.target respondsToSelector:_cmd]) {
        [self.target URLSession:session task:task didFinishCollectingMetrics:metrics];
    }
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    if (response) {
        LSURLSessionTaskAgent *agent = [LSURLSessionTaskAgent agentForTask:dataTask];
        if (agent) {
            agent.model.response = response;
            agent.model.connectionEstablishedTime = [NSDate date];
        }
    }
    
    if ([self.target respondsToSelector:_cmd]) {
        [self.target URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
    } else {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    [LSURLSessionTaskAgent removeAgentForTask:dataTask];
    
    if ([self.target respondsToSelector:_cmd]) {
        [self.target URLSession:session dataTask:dataTask didBecomeDownloadTask:downloadTask];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask {
    if ([self.target respondsToSelector:_cmd]) {
        [self.target URLSession:session dataTask:dataTask didBecomeStreamTask:streamTask];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    LSURLSessionTaskAgent *agent = [LSURLSessionTaskAgent agentForTask:dataTask];
    if (agent) {
        agent.model.responseSize = data.length;
    }
    
    if ([self.target respondsToSelector:_cmd]) {
        [self.target URLSession:session dataTask:dataTask didReceiveData:data];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse * _Nullable cachedResponse))completionHandler {
    if ([self.target respondsToSelector:_cmd]) {
        [self.target URLSession:session dataTask:dataTask willCacheResponse:proposedResponse completionHandler:completionHandler];
    } else {
        completionHandler(proposedResponse);
    }
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    if ([self.target respondsToSelector:_cmd]) {
        [self.target URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if ([self.target respondsToSelector:_cmd]) {
        [self.target URLSession:session downloadTask:downloadTask didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    if ([self.target respondsToSelector:_cmd]) {
        [self.target URLSession:session downloadTask:downloadTask didResumeAtOffset:fileOffset expectedTotalBytes:expectedTotalBytes];
    }
}

#pragma mark - NSURLSessionStreamDelegate

- (void)URLSession:(NSURLSession *)session readClosedForStreamTask:(NSURLSessionStreamTask *)streamTask {
    if ([self.target respondsToSelector:_cmd]) {
        [self.target URLSession:session readClosedForStreamTask:streamTask];
    }
}

- (void)URLSession:(NSURLSession *)session writeClosedForStreamTask:(NSURLSessionStreamTask *)streamTask {
    if ([self.target respondsToSelector:_cmd]) {
        [self.target URLSession:session writeClosedForStreamTask:streamTask];
    }
}

- (void)URLSession:(NSURLSession *)session betterRouteDiscoveredForStreamTask:(NSURLSessionStreamTask *)streamTask {
    if ([self.target respondsToSelector:_cmd]) {
        [self.target URLSession:session betterRouteDiscoveredForStreamTask:streamTask];
    }
}

- (void)URLSession:(NSURLSession *)session streamTask:(NSURLSessionStreamTask *)streamTask didBecomeInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
    if ([self.target respondsToSelector:_cmd]) {
        [self.target URLSession:session streamTask:streamTask didBecomeInputStream:inputStream outputStream:outputStream];
    }
}

@end
