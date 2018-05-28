//
//  LSViewControllerTransitionTraceDataModel.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/27.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSViewControllerTransitionTraceDataModel.h"
#import "NSMutableDictionary+LSSafeAdd.h"

@interface LSViewControllerTransitionTraceDataModel ()

@property (nonatomic, strong, readwrite) NSString *viewControllerTrace;
@property (nonatomic, strong, readwrite) NSString *visibleViewControllerName;

@end
@implementation LSViewControllerTransitionTraceDataModel

- (instancetype)initWithBuilder:(void(^)(LSViewControllerTransitionTraceDataBuilder *))builder {
    if (self = [super init]) {
        LSViewControllerTransitionTraceDataBuilder *b = [[LSViewControllerTransitionTraceDataBuilder alloc] init];
        builder(b);
        
        _viewControllerTrace = b.viewControllerTrace;
        _visibleViewControllerName = b.visibleViewControllerName;
    }
    
    return self;
}

#pragma mark - LSDictionaryConvertable

- (instancetype)instanceWithData:(NSDictionary *)dict {
    if (![dict isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    LSViewControllerTransitionTraceDataModel *model = [[LSViewControllerTransitionTraceDataModel alloc] init];
    
    model.viewControllerTrace = dict[@"viewControllerTrace"];
    model.visibleViewControllerName = dict[@"visibleViewControllerName"];
    
    return model;
}

- (NSDictionary *)convertedData {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    [result ls_safeAddObject:self.viewControllerTrace key:@"viewControllerTrace"];
    [result ls_safeAddObject:self.visibleViewControllerName key:@"visibleViewControllerName"];
    
    return result.copy;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
#define e(x) \
[aCoder encodeObject:self.x forKey:@#x];
    
    e(viewControllerTrace)
    e(visibleViewControllerName)
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
#define d(x) \
_##x = [aDecoder decodeObjectForKey:@#x];
    
    if (self = [super init]) {
        d(viewControllerTrace)
        d(visibleViewControllerName)
    }
    
    return self;
}

@end

@implementation LSViewControllerTransitionTraceDataBuilder

@end
