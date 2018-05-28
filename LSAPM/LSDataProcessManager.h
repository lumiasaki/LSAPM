//
//  LSDataProcessManager.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/10.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSDataProcessor.h"
#import "LSDataProcessorPriority.h"

@class LSMonitorManager;
@class LSAPM;
@class LSDataPassToProcessorModel;

@interface LSDataProcessManager : NSObject

@property (nonatomic, weak) LSAPM *apm;

- (void)addProcessor:(id<LSDataProcessor>)processor;
- (void)removeProcessor:(id<LSDataProcessor>)processor;

- (NSArray<id<LSDataProcessor>> *)currentProcessors;

- (void)ready;
- (void)stopAll;

- (void)receive:(LSDataPassToProcessorModel *)unifiedData;

@end
