//
//  LSFloatingWindowProcessor.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/28.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LSDataProcessor.h"

@interface LSFloatingWindowProcessor : NSObject<LSDataProcessor>

@property (nonatomic, strong) UIView *floatingWindowSuperview;

@end
