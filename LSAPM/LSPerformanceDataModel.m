//
//  LSPerformanceDataModel.m
//  LSAPM
//
//  Created by Lumia_Saki on 2017/5/13.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSPerformanceDataModel.h"
#import "NSMutableDictionary+LSSafeAdd.m"

@interface LSPerformanceDataModel ()

@property (nonatomic, strong, readwrite) NSNumber *appMemoryUsage;
@property (nonatomic, strong, readwrite) NSNumber *instantFps;
@property (nonatomic, strong, readwrite) NSNumber *currentAppCpu;

@end
@implementation LSPerformanceDataModel

- (instancetype)initWithBuilder:(void (^)(LSPerformanceDataModelBuilder *))builder {
    if (self = [super init]) {
        LSPerformanceDataModelBuilder *b = [[LSPerformanceDataModelBuilder alloc] init];
        builder(b);
        
        _instantFps = b.instantFps;
        _appMemoryUsage = b.appMemoryUsage;
        _currentAppCpu = b.currentAppCpu;
    }
    
    return self;
}

#pragma mark - LSDictionaryConvertable

- (instancetype)instanceWithData:(NSDictionary *)dict {
    if (![dict isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    LSPerformanceDataModel *model = [[LSPerformanceDataModel alloc] init];
    
    if (!model) {
        return nil;
    }
    
    model.appMemoryUsage = dict[@"appMemoryUsage"];
    model.instantFps = dict[@"instantFps"];
    model.currentAppCpu = dict[@"currentAppCpu"];
    
    return model;
}

- (NSDictionary *)convertedData {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    [result ls_safeAddObject:self.appMemoryUsage key:@"appMemoryUsage"];
    [result ls_safeAddObject:self.instantFps key:@"instantFps"];
    [result ls_safeAddObject:self.currentAppCpu key:@"currentAppCpu"];
    
    return result.copy;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
#define e(x) \
[aCoder encodeObject:self.x forKey:@#x];
    
    e(appMemoryUsage)
    e(instantFps)
    e(currentAppCpu)
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
#define d(x) \
_##x = [aDecoder decodeObjectForKey:@#x];
    
    if (self = [super init]) {
        d(appMemoryUsage)
        d(instantFps)
        d(currentAppCpu)
    }
    
    return self;
}

@end

@implementation LSPerformanceDataModelBuilder

@end
