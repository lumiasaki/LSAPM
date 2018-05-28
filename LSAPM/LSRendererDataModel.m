//
//  LSRendererDataModel.m
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/24.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSRendererDataModel.h"
#import "NSMutableDictionary+LSSafeAdd.h"

@interface LSRendererDataModel ()

@property (nonatomic, strong, readwrite) NSString *viewControllerName;
@property (nonatomic, strong, readwrite) NSNumber *deltaOfViewDidLoadToViewWillAppear;
@property (nonatomic, strong, readwrite) NSNumber *deltaOfViewWillAppearToViewDidAppear;

@end
@implementation LSRendererDataModel

- (instancetype)initWithBuilder:(void (^)(LSRendererDataBuilder *))builder {
    if (self = [super init]) {
        LSRendererDataBuilder *b = [[LSRendererDataBuilder alloc] init];
        builder(b);
        
        _deltaOfViewDidLoadToViewWillAppear = b.deltaOfViewDidLoadToViewWillAppear;
        _deltaOfViewWillAppearToViewDidAppear = b.deltaOfViewWillAppearToViewDidAppear;
    }
    
    return self;
}

#pragma mark - LSDictionaryConvertable

- (instancetype)instanceWithData:(NSDictionary *)dict {
    if (![dict isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    LSRendererDataModel *model = [[LSRendererDataModel alloc] init];
    
    model.viewControllerName = dict[@"viewControllerName"];
    model.deltaOfViewDidLoadToViewWillAppear = dict[@"deltaOfViewDidLoadToViewWillAppear"];
    model.deltaOfViewWillAppearToViewDidAppear = dict[@"deltaOfViewDidLoadToViewWillAppear"];
    
    return model;
}

- (NSDictionary *)convertedData {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    [result ls_safeAddObject:self.viewControllerName key:@"viewControllerName"];
    [result ls_safeAddObject:self.deltaOfViewDidLoadToViewWillAppear key:@"deltaOfViewDidLoadToViewWillAppear"];
    [result ls_safeAddObject:self.deltaOfViewWillAppearToViewDidAppear key:@"deltaOfViewWillAppearToViewDidAppear"];
    
    return result.copy;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
#define e(x) \
[aCoder encodeObject:self.x forKey:@#x]
    
    e(viewControllerName);
    e(deltaOfViewDidLoadToViewWillAppear);
    e(deltaOfViewWillAppearToViewDidAppear);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
#define d(x) \
_##x = [aDecoder decodeObjectForKey:@#x]
    
    if (self = [super init]) {
        d(viewControllerName);
        d(deltaOfViewDidLoadToViewWillAppear);
        d(deltaOfViewWillAppearToViewDidAppear);
    }
    
    return self;
}

@end

@implementation LSRendererDataBuilder

@end
