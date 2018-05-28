//
//  LSURLSessionTaskAgent.h
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/24.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LSNetworkBasicRecordModel;

@interface LSURLSessionTaskAgent : NSObject

@property (nonatomic, strong, readonly) LSNetworkBasicRecordModel *model;

/**
 *  Register agent for ID
 *
 *  @param agent agent
 *  @param aID task ID
 */
+ (void)registerAgent:(LSURLSessionTaskAgent *)agent forID:(NSString *)aID;

/**
 *  Get agent with the given ID
 *
 *  @param aID task ID
 *
 *  @return agent
 */
+ (instancetype)agentForID:(NSString *)aID;

/**
 *  Remove agent
 *
 *  @param aID task ID
 */
+ (void)removeAgentForID:(NSString *)aID;

/**
 *  Register ID for task
 *
 *  @param aID  task ID
 *  @param task session task
 */
+ (void)registerID:(NSString *)aID forTask:(NSURLSessionTask *)task;

/**
 *  Get the ID of task
 *
 *  @param task data task
 *
 *  @return task ID
 */
+ (NSString *)idForTask:(NSURLSessionTask *)task;

/**
 *  Get the agent by task
 *
 *  @param task session task
 *
 *  @return agent or nil
 */
+ (instancetype)agentForTask:(NSURLSessionTask *)task;

/**
 *  Remove agent
 *
 *  @param task session task
 */
+ (void)removeAgentForTask:(NSURLSessionTask *)task;

@end
