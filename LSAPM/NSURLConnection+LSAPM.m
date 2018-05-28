//
//  NSURLConnection+LSAPM.m
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/24.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "NSURLConnection+LSAPM.h"
#import "LSNetworkModule.h"
#import "LSURLConnectionMITM.h"
#import "LSNetworkBasicRecordModel.h"

static LSNetworkModule *ls_networkMonitorModule = nil;

@implementation NSURLConnection (LSAPM)

+ (void)setLs_networkMonitorModule:(LSNetworkModule *)module {
    ls_networkMonitorModule = module;
}

+ (void)ls_startMonitoring {
    [LSUtils swizzleClassMethods:self originalSelector:@selector(sendAsynchronousRequest:queue:completionHandler:) swizzledSelector:@selector(ls_sendAsynchronousRequest:queue:completionHandler:)];
    [LSUtils swizzleClassMethods:self originalSelector:@selector(sendSynchronousRequest:returningResponse:error:) swizzledSelector:@selector(ls_sendSynchronousRequest:returningResponse:error:)];
    [LSUtils swizzleClassMethods:self originalSelector:@selector(connectionWithRequest:delegate:) swizzledSelector:@selector(ls_connectionWithRequest:delegate:)];
    
    [LSUtils swizzleInstanceMethods:self originalSelector:@selector(initWithRequest:delegate:) swizzledSelector:@selector(ls_initWithRequest:delegate:)];
    [LSUtils swizzleInstanceMethods:self originalSelector:@selector(initWithRequest:delegate:startImmediately:) swizzledSelector:@selector(ls_initWithRequest:delegate:startImmediately:)];
}

+ (void)ls_invalidate {
    // TODO: 保存原始selector，恢复
    
    ls_networkMonitorModule = nil;
}

#pragma mark - Network Request

+ (void)ls_sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))handler {
    if (ls_networkMonitorModule.requestDecorator) {
        request = [ls_networkMonitorModule.requestDecorator canonicalRequest:request];
    }
    
    NSDate *startTime = [NSDate date];
    
    [self ls_sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (ls_networkMonitorModule) {
            LSNetworkBasicRecordModel *model = [[LSNetworkBasicRecordModel alloc] init];
            model.endTime = [NSDate date];
            model.startTime = startTime;
            model.responseSize = data.length;
            model.request = request.copy;
            model.response = response.copy;
            model.error = connectionError.copy;            
            
            [ls_networkMonitorModule record:model];
        }
        
        handler(response, data, connectionError);
    }];
}

+ (NSData *)ls_sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error {
    if (ls_networkMonitorModule.requestDecorator) {
        request = [ls_networkMonitorModule.requestDecorator canonicalRequest:request];
    }
    
    NSDate *startTime = [NSDate date];
    
    NSData *resultData = [self ls_sendSynchronousRequest:request returningResponse:response error:error];
    
    if (ls_networkMonitorModule) {
        LSNetworkBasicRecordModel *model = [[LSNetworkBasicRecordModel alloc] init];
        model.endTime = [NSDate date];
        model.startTime = startTime;
        model.responseSize = resultData.length;
        model.request = request.copy;
        model.response = [*response copy];
        model.error = [*error copy];
        
        [ls_networkMonitorModule record:model];
    }
    
    return resultData;
}

#pragma mark - Network Init

+ (NSURLConnection *)ls_connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate {
    if (ls_networkMonitorModule.requestDecorator) {
        request = [ls_networkMonitorModule.requestDecorator canonicalRequest:request];
    }
    
    LSURLConnectionMITM *agent = [[LSURLConnectionMITM alloc] initWithTarget:delegate];
    
    return [self ls_connectionWithRequest:request delegate:agent];
}

- (instancetype)ls_initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately {
    if (ls_networkMonitorModule.requestDecorator) {
        request = [ls_networkMonitorModule.requestDecorator canonicalRequest:request];
    }
    
    LSURLConnectionMITM *agent = [[LSURLConnectionMITM alloc] initWithTarget:delegate];
    
    return [self ls_initWithRequest:request delegate:agent startImmediately:startImmediately];
}

- (instancetype)ls_initWithRequest:(NSURLRequest *)request delegate:(id)delegate {
    if (ls_networkMonitorModule.requestDecorator) {
        request = [ls_networkMonitorModule.requestDecorator canonicalRequest:request];
    }
    
    LSURLConnectionMITM *agent = [[LSURLConnectionMITM alloc] initWithTarget:delegate];
    
    return [self ls_initWithRequest:request delegate:agent];
}

@end
