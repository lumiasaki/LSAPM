//
//  LSAppStateChangedResponsable.h
//  LSAPM
//
//  Created by Lumia_Saki on 2017/5/18.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LSAppStateChangedResponsable <NSObject>

@optional
- (void)applicationDidBecomeActive;
- (void)applicationWillResignActive;

@end
