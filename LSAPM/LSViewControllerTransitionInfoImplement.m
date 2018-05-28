//
//  LSViewControllerTransitionInfoImplement.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/27.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSViewControllerTransitionInfoImplement.h"

@implementation LSViewControllerTransitionInfoImplement

- (NSString *)viewControllerTransitionInfo {
    NSAssert(self.navigationController, @"If use default implement to get view controller transition trace, should assign navigation controller first");
    
    NSMutableString *result = [[NSMutableString alloc] init];
    
    for (UIViewController *controller in self.navigationController.viewControllers) {
        NSString *name = NSStringFromClass(controller.class);
        
        [result appendFormat:@"%@ - ", name];
    }
    
    return result.copy;
}

- (NSString *)visibleViewControllerName {
    NSAssert(self.navigationController, @"If use default implement to get view controller transition trace, should assign navigation controller first");
    
    NSString *result = NSStringFromClass(self.navigationController.visibleViewController.class);
    
    return result;
}

@end
