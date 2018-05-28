//
//  NSURLSession+LSAPM.m
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/24.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "NSURLSession+LSAPM.h"
#import "LSNetworkModule.h"
#import "LSURLSessionTaskAgent.h"
#import "LSNetworkBasicRecordModel.h"
#import "LSURLSessionMITM.h"
#import <objc/runtime.h>

static LSNetworkModule *ls_networkMonitorModule;

typedef void (^DataTaskCompletionBlock)(NSData*,NSURLResponse*,NSError*);

NSURLSessionDataTask* (*origin_DataTaskWithRequestAndCompletionHandler)(id, SEL, NSURLRequest*, DataTaskCompletionBlock) = NULL;
void (*origin_NSCFLocalDataTask_resume)(id,SEL) = NULL;
void (*origin_NSURLSessionTask_resume)(id,SEL) = NULL;

#pragma mark - NSURLSessionTask

static void LSAPM_NSCFLocalDataTask_Resume(id self, SEL _cmd)
{
    LSURLSessionTaskAgent *agent = [LSURLSessionTaskAgent agentForTask:self];
    if (agent) {
        agent.model.startTime = [NSDate date];
    }
    
    origin_NSCFLocalDataTask_resume(self, _cmd);
}

static void LSAPM_NSURLSessionTask_Resume(id self, SEL _cmd)
{
    LSURLSessionTaskAgent *agent = [LSURLSessionTaskAgent agentForTask:self];
    if (agent) {
        agent.model.startTime = [NSDate date];
    }
    
    origin_NSURLSessionTask_resume(self, _cmd);
}


#pragma mark - NSURLSession

static NSURLSessionTask *LSAPM_NSURLSession_DataTaskWithRequestAndCompletionHandler(id self, SEL _cmd, NSURLRequest *request, DataTaskCompletionBlock completionHandler)
{
    NSURLSessionDataTask *task = nil;
    NSString *aID = [[NSUUID UUID] UUIDString];
    
    if (ls_networkMonitorModule.requestDecorator) {
        request = [ls_networkMonitorModule.requestDecorator canonicalRequest:request];
    }
    
    if (completionHandler) {
        task = origin_DataTaskWithRequestAndCompletionHandler(self, _cmd, request, ^(NSData *data,
                                                                                     NSURLResponse *response,
                                                                                     NSError *error) {
            LSURLSessionTaskAgent *agent = [LSURLSessionTaskAgent agentForID:aID];
            if (agent) {
                // TODO: 这个建立连接的时间好像不太对，先放过
                agent.model.connectionEstablishedTime = [NSDate date];
                
                agent.model.response = response;
                
                agent.model.responseSize = data.length;
                
                agent.model.error = error;
                
                agent.model.endTime = [NSDate date];
                
                [ls_networkMonitorModule record:agent.model];
                
                [LSURLSessionTaskAgent removeAgentForID:aID];
            }
            
            completionHandler(data, response, error);
        });
    } else {
        task = origin_DataTaskWithRequestAndCompletionHandler(self, _cmd, request, completionHandler);
    }
    
    LSURLSessionTaskAgent *agent = [[LSURLSessionTaskAgent alloc] init];    
    agent.model.request = request;
    [LSURLSessionTaskAgent registerAgent:agent forID:aID];
    [LSURLSessionTaskAgent registerID:aID forTask:task];
    
    return task;
}

@implementation NSURLSession (LSAPM)

+ (void)setLs_networkMonitorModule:(LSNetworkModule *)module {
    ls_networkMonitorModule = module;
}

+ (void)ls_startMonitoring {
    NSAssert(ls_networkMonitorModule, @"should assign network monitor module before start recording network traffic");
        
    if (![NSURLSession class]) {
        // iOS 6 compatible
        return;
    }
    
    [LSUtils swizzleClassMethods:self originalSelector:@selector(sessionWithConfiguration:delegate:delegateQueue:) swizzledSelector:@selector(ls_sessionWithConfiguration:delegate:delegateQueue:)];
    
    Class c;
    SEL selMethod;
    IMP impOverrideMethod;
    Method origMethod;
    
    
    // NSURLSession is a class cluster, we cannot hook the toplevel class only.
    // NSURLSession dataTaskWithRequest:completionHandler:
    c = NSClassFromString(@"__NSCFURLSession"); // iOS 7
    if (!c) {
        c = NSClassFromString(@"__NSURLSessionLocal"); // iOS 8+
    }
    selMethod = @selector(dataTaskWithRequest:completionHandler:);
    impOverrideMethod = (IMP)LSAPM_NSURLSession_DataTaskWithRequestAndCompletionHandler;
    origMethod = class_getInstanceMethod(c, selMethod);
    origin_DataTaskWithRequestAndCompletionHandler = (void *)method_getImplementation(origMethod);
    
    if (origin_DataTaskWithRequestAndCompletionHandler) {
        method_setImplementation(origMethod, impOverrideMethod);
    }
    
    // NSURLSessionTask resume
    c = NSClassFromString(@"NSURLSessionTask");
    selMethod = @selector(resume);
    impOverrideMethod = (IMP)LSAPM_NSURLSessionTask_Resume;
    origMethod = class_getInstanceMethod(c, selMethod);
    origin_NSURLSessionTask_resume = (void *)method_getImplementation(origMethod);
    
    if (origin_NSURLSessionTask_resume) {
        method_setImplementation(origMethod, impOverrideMethod);
    }
    
    // __NSCFLocalDataTask resume
    c = NSClassFromString(@"__NSCFLocalDataTask");
    selMethod = @selector(resume);
    impOverrideMethod = (IMP)LSAPM_NSCFLocalDataTask_Resume;
    origMethod = class_getInstanceMethod(c, selMethod);
    origin_NSCFLocalDataTask_resume = (void *)method_getImplementation(origMethod);
    
    if (origin_NSCFLocalDataTask_resume) {
        method_setImplementation(origMethod, impOverrideMethod);
    }
}

+ (void)ls_invalidate {
    // TODO: 保存原始selector，恢复
    ls_networkMonitorModule = nil;
}

#pragma mark - Class methods

+ (NSURLSession *)ls_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(nullable id <NSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue
{
    LSURLSessionMITM *agent = [[LSURLSessionMITM alloc] initWithTarget:delegate];
    agent.module = ls_networkMonitorModule;
    return [self ls_sessionWithConfiguration:configuration delegate:(id)agent delegateQueue:queue];
}

@end
