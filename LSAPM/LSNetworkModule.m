//
//  LSNetworkModule.m
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/24.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSNetworkModule.h"
#import "LSNetworkBasicRecordModel.h"
#import "LSNetworkDataModel.h"
#import "LSMonitorManager.h"
#import "LSNetworkAnalyzerImplement.h"

#import "NSURLConnection+LSAPM.h"
#import "NSURLSession+LSAPM.h"

LSMonitor(LSNetworkModule)

static const char* WORKER_QUEUE_IDENTIFIER = "com.ls.feature.network_monitor_queue";

@interface LSNetworkModule ()
{
    dispatch_queue_t _queue;
}

@end

@implementation LSNetworkModule

@synthesize monitorManager = _monitorManager;

- (instancetype)init {
    if (self = [super init]) {
        _queue = dispatch_queue_create(WORKER_QUEUE_IDENTIFIER, DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

+ (NSString *)moduleIdentifier {
    return kLSNetworkModuleIdentifier;
}

+ (Class)dataModelClass {
    return LSNetworkDataModel.class;
}

- (void)responseForMessage:(NSDictionary *)msg response:(void (^)(id))response {}

- (void)start {
    // TODO: 可否通过统一在worker queue上确保线程安全？
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!self.networkAnalysisProcessor) {
            // only access here when there is no custom analyzer been set.
            self.networkAnalysisProcessor = [[LSNetworkAnalyzerImplement alloc] init];
        }
        
        [NSURLConnection setLs_networkMonitorModule:self];
        [NSURLConnection ls_startMonitoring];
        
        [NSURLSession setLs_networkMonitorModule:self];
        [NSURLSession ls_startMonitoring];
    });
}

- (void)stop {
    // TODO: 可否通过统一在worker queue上确保线程安全？
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSURLConnection ls_invalidate];
        [NSURLSession ls_invalidate];
    });
}

- (void)record:(LSNetworkBasicRecordModel *)recordModel {
    // to avoid potential thread troubles of networkAnalysisProcessor
    dispatch_async(_queue, ^{
        LSNetworkDataModel *analysedData = [self.networkAnalysisProcessor analyseRecording:recordModel];
        
        LSDataPassToProcessorModel *model = [[LSDataPassToProcessorModel alloc] init];
        
        // TODO: 确认哪些模块可以响应
        model.canResponse = @[kLSLoggerProcessorIdentifier];
        model.eventName = kLSEventNameNetworkRequest;
        model.network = analysedData;
        
        [self.monitorManager sendUnifiedDataToDataProcessor:model];
    });
}

@end
