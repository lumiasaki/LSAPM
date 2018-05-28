//
//  LSStacktraceDataModel.h
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/24.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSDictionaryConvertable.h"

@interface LSStacktraceDataBuilder : NSObject

@property (nonatomic, strong) NSString *stacktrace;

@end
@interface LSStacktraceDataModel : NSObject<LSDictionaryConvertable, NSCoding>

@property (nonatomic, strong, readonly) NSString *stacktrace;

- (instancetype)initWithBuilder:(void(^)(LSStacktraceDataBuilder *))builder;

@end
