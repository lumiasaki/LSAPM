//
//  LSDataProcessor.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/10.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSBootable.h"
#import "LSPriorityable.h"
#import "LSAppStateChangedResponsable.h"

@class LSDataProcessManager;
@class LSDataPassToProcessorModel;

@protocol LSDataProcessor <NSObject, LSBootable, LSPriorityable, LSAppStateChangedResponsable>

@required
@property (nonatomic, weak) LSDataProcessManager *processManager;

+ (NSString *)processorIdentifier;

- (BOOL)responseSwitch;

@optional
// data flow, behave like middle-ware, !!!SHOULD BE PURE FUNTION!!!
// if 'responseSwitch' return YES, ProcessManager will invoke this method.
- (void)process:(LSDataPassToProcessorModel *)original;

@end
