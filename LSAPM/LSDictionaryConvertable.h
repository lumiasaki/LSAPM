//
//  LSDictionaryConvertable.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/21.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LSDictionaryConvertable <NSObject>

@required
- (NSDictionary *)convertedData;

@optional
- (instancetype)instanceWithData:(NSDictionary *)dict;

@end
