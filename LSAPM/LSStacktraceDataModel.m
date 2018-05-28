//
//  LSStacktraceDataModel.m
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/24.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSStacktraceDataModel.h"
#import "NSMutableDictionary+LSSafeAdd.h"

@interface LSStacktraceDataModel ()

@property (nonatomic, strong, readwrite) NSString *stacktrace;

@end
@implementation LSStacktraceDataModel

- (instancetype)initWithBuilder:(void (^)(LSStacktraceDataBuilder *))builder {
    if (self = [super init]) {
        LSStacktraceDataBuilder *b = [[LSStacktraceDataBuilder alloc] init];
        builder(b);
                
        _stacktrace = b.stacktrace;
    }
    
    return self;
}

#pragma mark - LSDictionaryConvertable

- (instancetype)instanceWithData:(NSDictionary *)dict {
    if (![dict isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    LSStacktraceDataModel *model = [[LSStacktraceDataModel alloc] init];
    
    model.stacktrace = dict[@"stacktrace"];
    
    return model;
}

- (NSDictionary *)convertedData {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    [result ls_safeAddObject:self.stacktrace key:@"stacktrace"];
    
    return result.copy;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
#define e(x) \
[aCoder encodeObject:self.x forKey:@#x];
    
    e(stacktrace)
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
#define d(x) \
_##x = [aDecoder decodeObjectForKey:@#x];
    
    if (self = [super init]) {
        d(stacktrace)
    }
    
    return self;
}

@end

@implementation LSStacktraceDataBuilder

@end
