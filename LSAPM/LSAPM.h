//
//  LSAPM.h
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/10.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LSMonitorModule.h"
#import "LSDataProcessor.h"

@class LSMonitorManager;
@class LSDataProcessManager;
@class LSAPMConfiguration;

@interface LSAPM : NSObject

@property (nonatomic, strong, readonly) LSMonitorManager *monitorManager;
@property (nonatomic, strong, readonly) LSDataProcessManager *processManager;

@property (nonatomic, strong) LSAPMConfiguration *configuration;

@property (nonatomic, assign, getter=isRunning, readonly) BOOL running;

+ (instancetype)sharedInstance;

/**
 * use default configuration, processor set and module set to start monitoring.
 */
- (void)start;

/**
 * custom processors and modules
 */
- (void)startWithModules:(NSSet<Class> *)modules
              processors:(NSArray<Class> *)processors
additionalStepsToModule:(void(^)(id<LSMonitorModule>))moduleBlock
additionalStepsToProcessor:(void(^)(id<LSDataProcessor>))processorBlock;

- (void)stop;
- (void)invalidate;

@end
