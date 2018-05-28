//
//  LSViewControllerTransitionInfoImplement.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/27.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LSViewControllerTransitionInfoProvider.h"

@interface LSViewControllerTransitionInfoImplement : NSObject<LSViewControllerTransitionInfoProvider>

@property (nonatomic, strong) UINavigationController *navigationController;

@end
