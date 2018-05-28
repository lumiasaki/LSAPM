//
//  LSURLSessionTaskAgent.m
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/24.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSURLSessionTaskAgent.h"
#import "LSNetworkBasicRecordModel.h"

static dispatch_queue_t urlSessionTaskAgentQueue = NULL;

static NSMutableDictionary *agentTaskMap;
static NSMapTable *taskIDMap;

static NSRecursiveLock *globalLock()
{
    static NSRecursiveLock *gLock;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        gLock = [[NSRecursiveLock alloc] init];
    });
    
    return gLock;
}

#define LOCK [globalLock() lock];
#define UNLOCK [globalLock() unlock];

@implementation LSURLSessionTaskAgent

- (instancetype)init {
    if (self = [super init]) {
        _model = [[LSNetworkBasicRecordModel alloc] init];
    }
    
    return self;
}

+ (void)registerAgent:(nullable LSURLSessionTaskAgent *)agent forID:(nullable NSString *)aID
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        agentTaskMap = [NSMutableDictionary dictionary];
    });
    
    if (!aID) {
        return;
    }
    
    LOCK
    
    [agentTaskMap setObject:agent forKey:aID];
    
    UNLOCK
}

+ (nullable instancetype)agentForID:(nullable NSString *)aID
{
    if (!aID) {
        return nil;
    }
    
    LSURLSessionTaskAgent *agent;
    
    LOCK
    
    agent = [agentTaskMap objectForKey:aID];
    
    UNLOCK
    
    return agent;
}

+ (void)removeAgentForID:(nullable NSString *)aID
{
    if (!aID) {
        return;
    }
    
    LOCK
    
    [agentTaskMap removeObjectForKey:aID];
    
    UNLOCK
}

+ (void)registerID:(nullable NSString *)aID forTask:(nullable NSURLSessionTask *)task
{
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        // weak key and strong value
        taskIDMap = [NSMapTable weakToStrongObjectsMapTable];
    });
    
    if (!aID || !task) {
        return;
    }
    
    LOCK
    
    [taskIDMap setObject:aID forKey:task];
    
    UNLOCK
}

+ (nullable NSString *)idForTask:(nullable NSURLSessionTask *)task
{
    if (!task) {
        return nil;
    }
    
    NSString *aID;
    
    LOCK
    
    aID = [taskIDMap objectForKey:task];
    
    UNLOCK
    
    return aID;
}

+ (nullable instancetype)agentForTask:(nullable NSURLSessionTask *)task
{
    if (!task) {
        return nil;
    }
    
    LSURLSessionTaskAgent *agent;
    
    LOCK
    
    NSString *aID = [taskIDMap objectForKey:task];
    if (aID) {
        agent = [self agentForID:aID];
    }
    
    UNLOCK
    
    return agent;
}

+ (void)removeAgentForTask:(nullable NSURLSessionTask *)task
{
    if (!task) {
        return;
    }
    
    LOCK
    
    NSString *aID = [taskIDMap objectForKey:task];
    if (aID) {
        [self removeAgentForID:aID];
    }
    
    UNLOCK
}

@end
