//
//  LSRendererDataModel.h
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/24.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSDictionaryConvertable.h"

@interface LSRendererDataBuilder : NSObject

@property (nonatomic, strong) NSString *viewControllerName;
@property (nonatomic, strong) NSNumber *deltaOfViewDidLoadToViewWillAppear;
@property (nonatomic, strong) NSNumber *deltaOfViewWillAppearToViewDidAppear;

@end

@interface LSRendererDataModel : NSObject<LSDictionaryConvertable, NSCoding>

@property (nonatomic, strong, readonly) NSString *viewControllerName;
@property (nonatomic, strong, readonly) NSNumber *deltaOfViewDidLoadToViewWillAppear;
@property (nonatomic, strong, readonly) NSNumber *deltaOfViewWillAppearToViewDidAppear;

- (instancetype)initWithBuilder:(void(^)(LSRendererDataBuilder *))builder;

@end
