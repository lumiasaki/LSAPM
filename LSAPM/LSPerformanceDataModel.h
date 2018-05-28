//
//  LSPerformanceDataModel.h
//  LSAPM
//
//  Created by Lumia_Saki on 2017/5/13.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSDictionaryConvertable.h"

@interface LSPerformanceDataModelBuilder : NSObject

@property (nonatomic, strong) NSNumber *appMemoryUsage;
@property (nonatomic, strong) NSNumber *instantFps;
@property (nonatomic, strong) NSNumber *currentAppCpu;

@end

@interface LSPerformanceDataModel : NSObject<LSDictionaryConvertable, NSCoding>

@property (nonatomic, strong, readonly) NSNumber *appMemoryUsage;
@property (nonatomic, strong, readonly) NSNumber *instantFps;
@property (nonatomic, strong, readonly) NSNumber *currentAppCpu;

- (instancetype)initWithBuilder:(void(^)(LSPerformanceDataModelBuilder *))builder;

@end
