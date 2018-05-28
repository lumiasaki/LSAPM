//
//  LSLoggerTemp.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/13.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSLoggerTemp.h"
#import "LSDataProcessManager.h"

LSProcessor(LSLoggerTemp)

@interface LSLoggerTemp ()

@property (nonatomic, assign) BOOL enable;

@end
@implementation LSLoggerTemp

@synthesize processManager = _processManager;

- (void)start {}

- (void)stop {}

- (void)process:(LSDataPassToProcessorModel *)original {
    NSLog(@"%@", original);
}

+ (NSUInteger)priority {
    return LS_PROCESSOR_PRIORITY_Logger;
}

+ (NSString *)processorIdentifier {
    return kLSLoggerProcessorIdentifier;
}

- (BOOL)responseSwitch {
    return YES;
}

@end
