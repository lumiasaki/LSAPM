
//
//  LSBootable.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/13.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LSBootable <NSObject>

@required
- (void)start;
- (void)stop;

@end
