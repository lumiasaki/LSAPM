//
//  QLSDataUpload.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/5/23.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "QLSDataUpload.h"
#import "LSDataProcessManager.h"
#import "LSPersistenceNotificationName.h"
#import "QLSDataUploadConfiguration.h"
#import "LSAPM.h"
#import "QLSAPMConfiguration.h"
#import "LSAPMConfiguration.h"

LSProcessor(QLSDataUpload)

static const char *const WorkerQueueIdentifier = "com.ls.feature.data_upload_worker_queue";

@interface QLSDataUpload ()
{
    dispatch_queue_t _workerQueue;
}

@property (nonatomic, assign) NSInteger persistenceNotiReceivedCount;

@end

@implementation QLSDataUpload

@synthesize processManager = _processManager;

- (instancetype)init {
    if (self = [super init]) {
        _workerQueue = dispatch_queue_create(WorkerQueueIdentifier, DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

#pragma mark - LSDataProcessor Protocol

- (BOOL)responseSwitch {
    return NO;
}

+ (NSString *)processorIdentifier {
    return kQLSDataUploadProcessorIdentifier;
}

- (void)start {
    dispatch_async(_workerQueue, ^{
        assert([(QLSAPMConfiguration *)self.processManager.apm.configuration dataUploadConfiguration]);
        
        self.persistenceNotiReceivedCount = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(persistFinish:) name:LS_PERSISTENCE_FINISH_NOTIFICATION_IDENTIFIER object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(persistenceResponse:) name:LS_PERSISTENCE_FILES_RESPONSE_NOTIFICATION_IDENTIFIER object:nil];
        
        // use case for restart the app
        [self checkIfHasPendingPersistedFile];
    });
}

- (void)stop {
    dispatch_async(_workerQueue, ^{
        self.persistenceNotiReceivedCount = 0;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    });
}

+ (NSUInteger)priority {
    return LS_PROCESSOR_PRIORITY_Upload;
}

#pragma mark - Private

- (void)checkIfHasPendingPersistedFile {
    [self requestPersistData];
}

- (void)requestPersistData {
    [[NSNotificationCenter defaultCenter] postNotificationName:LS_REQUEST_PERSISTENCE_FILES_NOTIFICATION_IDENTIFIER object:nil];
}

- (void)dataDelivered {
    [[NSNotificationCenter defaultCenter] postNotificationName:LS_REMOVE_PERSISTENCE_FILES_NOTIFICATION_IDENTIFIER object:nil];
}

- (void)upload:(NSDictionary *)data dirs:(NSArray<NSString *> *)dirs failedCount:(NSUInteger)count {
    
}

static NSDictionary *paramFromModels(NSArray<LSDataPassToProcessorModel *> *models) {
    // TODO: 拼出参数
    return @{};
}

#pragma mark - LSPersistenceProcess Notification

- (void)persistFinish:(__unused NSNotification *)notification {
    dispatch_async(_workerQueue, ^{
        self.persistenceNotiReceivedCount += 1;
        
        if (self.persistenceNotiReceivedCount > ((QLSAPMConfiguration *)(self.processManager.apm.configuration)).dataUploadConfiguration.fileBufferSize) {
            [self requestPersistData];
            
            // clear work state
            self.persistenceNotiReceivedCount = 0;
        }
    });
}

- (void)persistenceResponse:(NSNotification *)notification {
    NSArray<NSDictionary *> *persistData = notification.userInfo[@"data"];
    
    if (!([persistData isKindOfClass:NSArray.class] && persistData.count > 0)) {
        return;
    }
    
    dispatch_async(_workerQueue, ^{
        // TODO: 取出persistData中的data部分，得到LSDataPassToProcessorModel实例，然后进行序列化后，进行网络上传
        
        // 1. extract出每个文件中的NSArray<LSDataPassToProcessorModel *> *
        // 2. 合并到一个数组中
        // 3. （进行兼容旧格式的转换）
        // 4. 序列化，上传
        // 5. 成功回调中将所有数据清除（通过向LSPersistenceModule请求服务）
        // 6. 若上传失败，重试（这里重试可能会需要一个重试窗口的策略，短时间内重试发现一直失败，则拉大重试窗口，达到一定的大小时不再拉大；超过最大窗口下的重试次数后，取消发送，等待下一次requestPersistData）
        
        // TODO: 需要避免pending的文件太多了，造成单个合并后的combinedModels数据量太大，传输成功率降低的问题（定一个maxSize，自动截取每一段[maxSize]的数据进行upload）
        
        NSArray *(^dataExtractor)(NSArray *(^f)(NSDictionary *)) = ^NSArray *(NSArray *(^f)(NSDictionary *)) {
            NSMutableArray *result = [[NSMutableArray alloc] init];
            
            for (NSDictionary *meta in persistData) {
                if ([meta isKindOfClass:NSDictionary.class]) {
                    [result addObjectsFromArray:f(meta)];
                }
            }
            
            return result.copy;
        };
        
        // extract all file dirs attached to models, convenience for purge data in success callback
        NSArray<NSString *> *attachedFileDirs = dataExtractor(^NSArray *(NSDictionary *dict) {
            if ([dict[@"fileName"] isKindOfClass:NSString.class]) {
                return @[dict[@"fileName"]];
            }
            
            return @[];
        });
        
        // extract all models from persistData
        NSArray<LSDataPassToProcessorModel *> *combinedModels = dataExtractor(^NSArray *(NSDictionary *dict) {
            if ([dict[@"data"] isKindOfClass:NSArray.class]) {
                return dict[@"data"];
            }
            
            return @[];
        });
        
        NSDictionary *param = paramFromModels(combinedModels);
        
        [self upload:param dirs:attachedFileDirs failedCount:0];
    });
}

@end
