//
//  LSPersistenceConfiguration.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/5/18.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LSPersistenceStrategy) {
    DataItemCount
};

@interface LSPersistenceConfiguration : NSObject

@property (nonatomic, assign) LSPersistenceStrategy persistenceStrategy; // Default is DataItemCount

// if strategy is item count, values below are available
@property (nonatomic, strong) NSNumber *pendingItemCount;

@end
