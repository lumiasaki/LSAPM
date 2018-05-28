//
//  LSDataProcessManager.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/10.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSDataProcessManager.h"
#import "LSUtils.h"

@interface LSDataProcessManager ()

@property (nonatomic, strong) NSMutableArray<id<LSDataProcessor>> *processors;

@end

@implementation LSDataProcessManager

#pragma mark - Public

- (void)addProcessor:(id<LSDataProcessor>)processor {
    NSAssert(processor, @"processor is nil");
    
    ls_executeOnDataProcessQueue(^{
        [self.processors addObject:processor];
    }, NO);
}

- (void)removeProcessor:(id<LSDataProcessor>)processor {
    NSAssert(processor, @"processor is nil");
    
    ls_executeOnDataProcessQueue(^{
        [self.processors removeObject:processor];
    }, NO);
}

- (NSArray<id<LSDataProcessor>> *)currentProcessors {
    return self.processors.copy;
}

- (void)ready {
    ls_executeOnDataProcessQueue(^{
        for (id<LSDataProcessor> processor in self.processors) {
            if ([processor respondsToSelector:@selector(start)]) {
                [processor start];
            }
        }
    }, NO);
}

- (void)stopAll {
    ls_executeOnDataProcessQueue(^{
        for (id<LSDataProcessor> processor in self.processors) {
            if ([processor respondsToSelector:@selector(stop)]) {
                [processor stop];
            }
        }
    }, NO);
}

- (void)receive:(LSDataPassToProcessorModel *)unifiedData {
    NSAssert(unifiedData, @"unifiedData is nil");
    NSAssert(unifiedData.canResponse, @"unified data should contain 'canResponse' section to describe which processors can response this data, value is identifier of processor");
    
    ls_executeOnDataProcessQueue(^{
        for (id<LSDataProcessor> processor in self.processors) {
            if (!processor.responseSwitch || ![unifiedData.canResponse containsObject:[processor.class processorIdentifier]]) {
                continue;
            }
            
            if ([processor respondsToSelector:@selector(process:)]) {
                // to avoid potential task process blocking
                dispatch_async(ProcessorsProcessQueue(), ^{
                    [processor process:unifiedData];
                });
            }
        }
    }, NO);
}

#pragma mark - Private

- (NSMutableArray<id<LSDataProcessor>> *)processors {
    if (!_processors) {
        _processors = [[NSMutableArray alloc] init];
    }
    
    return _processors;
}

static dispatch_queue_t ProcessorsProcessQueue() {
    static dispatch_queue_t Processors_Process_Queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Processors_Process_Queue = dispatch_queue_create("com.ls.feature.processors_process_worker_queue", DISPATCH_QUEUE_SERIAL);
    });
    
    return Processors_Process_Queue;
}

@end
