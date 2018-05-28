//
//  LSViewControllerTransitionTraceDataModel.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/27.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSDictionaryConvertable.h"

@interface LSViewControllerTransitionTraceDataBuilder : NSObject

@property (nonatomic, strong) NSString *viewControllerTrace;
@property (nonatomic, strong) NSString *visibleViewControllerName;

@end
@interface LSViewControllerTransitionTraceDataModel : NSObject<LSDictionaryConvertable, NSCoding>

@property (nonatomic, strong, readonly) NSString *viewControllerTrace;
@property (nonatomic, strong, readonly) NSString *visibleViewControllerName;

- (instancetype)initWithBuilder:(void(^)(LSViewControllerTransitionTraceDataBuilder *))builder;

@end
