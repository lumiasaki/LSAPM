//
//  LSViewControllerLoadTimeModule.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/18.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSMonitorModule.h"

@class LSViewControllerRecordModel;

@interface LSViewControllerLoadTimeModule : NSObject<LSMonitorModule>

- (void)record:(LSViewControllerRecordModel *)recordModel;

@end
