//
//  LSRegisterHelper.h
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/14.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LSDataInSection(secName) __attribute((used, section("__DATA,"#secName" ")))

@interface LSRegisterHelper : NSObject

+ (NSArray<Class> *)allMonitorModules;
+ (NSArray<Class> *)allProcessors;

@end
