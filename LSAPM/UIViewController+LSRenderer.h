//
//  UIViewController+LSRenderer.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/18.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSViewControllerLoadTimeModule;

@interface UIViewController (LSRenderer)

+ (void)setLs_viewControllerLoadMonitorModule:(LSViewControllerLoadTimeModule *)monitorModule;

// not thread safe, caller guaranteed
+ (void)ls_startMonitoring;
+ (void)ls_invalidate;

@end

@interface LSViewControllerRecordModel : NSObject

@property (nonatomic, strong, readonly) UIViewController *viewController;
@property (nonatomic, strong, readonly) NSString *methodName;
@property (nonatomic, assign) NSTimeInterval timestamp;

- (instancetype)initWithViewController:(UIViewController *)viewController recordedMethodName:(NSString *)methodName;

@end
