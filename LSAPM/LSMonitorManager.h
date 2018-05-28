//
//  LSMonitorManager.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/10.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSMonitorModule.h"

@class LSAPM;
@class LSDataPassToProcessorModel;

@interface LSMonitorManager : NSObject

@property (nonatomic, weak) LSAPM *apm;

- (void)addMonitorModule:(id<LSMonitorModule>)module;
- (void)removeMonitorModule:(id<LSMonitorModule>)module;

- (NSSet<id<LSMonitorModule>> *)monitorModules;

- (id<LSMonitorModule>)monitorWithClassName:(NSString *)className;
- (id<LSMonitorModule>)monitorWithIdentifier:(NSString *)moduleIdentifier;

- (void)ready;
- (void)stopAll;

// exchange messages between modules, 'from' should pass caller in
- (void)sendMessage:(NSDictionary *)msg
         fromModule:(id<LSMonitorModule>)from
           toModule:(id<LSMonitorModule>)to
           response:(void(^)(id))response;

// exchange messages between modules via their moduleIndentifier, 'fromID' should pass caller's moduleIdentifier in
- (void)sendMessage:(NSDictionary *)msg
       fromModuleID:(NSString *)fromID
         toModuleID:(NSString *)toID
           response:(void(^)(id))response;

// send to next layer - data process manager -, will ticks a timestamp for data automaticlly
- (void)sendUnifiedDataToDataProcessor:(LSDataPassToProcessorModel *)data;

@end
