//
//  LSViewControllerTransitionInfoProvider.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/27.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LSViewControllerTransitionInfoProvider <NSObject>

@required
- (NSString *)viewControllerTransitionInfo;

@optional
- (NSString *)visibleViewControllerName;

@end
