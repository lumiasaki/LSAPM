//
//  LSPersistenceStrategy.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/5/18.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LSDataPassToProcessorModel;
@class LSPersistenceConfiguration;

@protocol LSPersistenceFinishNotify <NSObject>

@required
- (void)finishPersisting;

@optional
- (void)sendDirectlyInEmergencyCase:(NSArray<NSDictionary *> *)data;

@end

@protocol LSPersistenceStrategy <NSObject>

@required
@property (nonatomic, weak) id<LSPersistenceFinishNotify> delegate;
@property (nonatomic, strong) LSPersistenceConfiguration *configuration;

- (void)receiveData:(LSDataPassToProcessorModel *)data;

- (NSArray<NSDictionary *> *)persistedData;
- (void)purgeData:(NSArray<NSDictionary *> *)toBePurgedData;

@end
