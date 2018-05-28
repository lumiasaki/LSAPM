//
//  LSPersistenceProcessor.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/5/18.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSPersistenceProcessor.h"
#import "LSPersistenceConfiguration.h"
#import "LSPersistenceStrategy.h"
#import "LSPersistenceNotificationName.h"
#import "LSDataProcessManager.h"
#import "LSAPM.h"
#import "LSAPMConfiguration.h"

#import "_LSPersistenceDataItemCount.h"

LSProcessor(LSPersistenceProcessor)

static const char *const WORK_QUEUE_IDENTIFIER = "com.ls.feature.persistence_worker_queue";

@interface LSPersistenceProcessor ()<LSPersistenceFinishNotify>
{
    dispatch_queue_t _workerQueue;
}

@property (nonatomic, strong) id<LSPersistenceStrategy> currentStrategyImpl;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *emergencyCaseDataPool;

@end

@implementation LSPersistenceProcessor

@synthesize processManager = _processManager;

- (instancetype)init {
    if (self = [super init]) {
        _workerQueue = dispatch_queue_create(WORK_QUEUE_IDENTIFIER, DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (void)start {
    dispatch_async(_workerQueue, ^{
        switch (self.persistenceConfiguration.persistenceStrategy) {
            case DataItemCount:
            default:
                self.currentStrategyImpl = [[_LSPersistenceDataItemCount alloc] init];
                break;
        }
        
        self.currentStrategyImpl.delegate = self;
        self.currentStrategyImpl.configuration = self.persistenceConfiguration;
        
        // register listeners
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestPersistenceFiles:) name:LS_REQUEST_PERSISTENCE_FILES_NOTIFICATION_IDENTIFIER object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removePersistenceFiles:) name:LS_REMOVE_PERSISTENCE_FILES_NOTIFICATION_IDENTIFIER object:nil];
        }
    });
}

- (void)stop {
    dispatch_async(_workerQueue, ^{
        self.currentStrategyImpl = nil;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    });
}

+ (NSString *)processorIdentifier {
    return kLSPersistenceProcessorIdentifier;
}

+ (NSUInteger)priority {
    return LS_PROCESSOR_PRIORITY_Persistence;
}

- (void)process:(LSDataPassToProcessorModel *)original {
    dispatch_async(_workerQueue, ^{
        [self.currentStrategyImpl receiveData:original];
    });
}

- (BOOL)responseSwitch {
    return YES;
}

#pragma mark - LSPersistenceStrategy Protocol

- (void)finishPersisting {
    dispatch_async(_workerQueue, ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LS_PERSISTENCE_FINISH_NOTIFICATION_IDENTIFIER object:nil];
    });
}

- (void)sendDirectlyInEmergencyCase:(NSArray<NSDictionary *> *)data {
    if (![data isKindOfClass:NSArray.class]) {
        return;
    }
    
    dispatch_async(_workerQueue, ^{
        [self.emergencyCaseDataPool addObjectsFromArray:data];
        
        [self fakeFinishPersisting];
    });
}

#pragma mark - Notifications

- (void)removePersistenceFiles:(NSNotification *)notification {
    NSArray<NSDictionary *> *needRemoveFiles = notification.userInfo[@"data"];
    
    if (needRemoveFiles) {
        dispatch_async(_workerQueue, ^{
            // TODO: 梳理removePersistedFiles的逻辑，需要考虑到app进程被意外杀死的情况，应该需要一个flag来做安全校验
            // TODO: 好像无论如何都不太好判断这种极端情况，因为进程被杀死的时机是任意的，所以不太好做校验，待想一个更好的方案
            // 暂时先通过后端对model中的uniqueId来进行去重。。。
            [self.currentStrategyImpl purgeData:needRemoveFiles];
        });
    }
}

- (void)requestPersistenceFiles:(NSNotification *)notification {
    dispatch_async(_workerQueue, ^{
        NSArray *fakePersistence = [[NSArray alloc] initWithArray:self.emergencyCaseDataPool];
        
        NSArray *realPersistence = [self.currentStrategyImpl persistedData];
        
        NSMutableArray *result = [[NSMutableArray alloc] initWithArray:realPersistence];
        [result addObjectsFromArray:fakePersistence];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:LS_PERSISTENCE_FILES_RESPONSE_NOTIFICATION_IDENTIFIER object:self userInfo:@{@"data": result.copy}];
        
        [self.emergencyCaseDataPool removeAllObjects];
    });
}

#pragma mark - Private

- (void)fakeFinishPersisting {
    [self finishPersisting];
}

- (LSPersistenceConfiguration *)persistenceConfiguration {
    return self.processManager.apm.configuration.persistenceConfiguration;
}

#pragma mark - Getter

- (NSMutableArray<NSDictionary *> *)emergencyCaseDataPool {
    if (!_emergencyCaseDataPool) {
        _emergencyCaseDataPool = [[NSMutableArray alloc] init];
    }
    
    return _emergencyCaseDataPool;
}

@end
