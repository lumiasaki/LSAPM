//
//  LSFloatingWindow.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/28.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSFloatingWindow : UIView

@property (nonatomic, strong) NSNumber *fps;
@property (nonatomic, strong) NSNumber *memory;
@property (nonatomic, strong) NSNumber *cpu;

- (void)anrOccurred:(NSString *)stacktrace;

@end
