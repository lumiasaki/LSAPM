//
//  LSDataProcessorPriority.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/5/23.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#define PROCESSOR_NAME(name) \
LS_PROCESSOR_PRIORITY_##name

typedef NS_ENUM(NSUInteger, LSDataProcessorPriorityValue) {
    PROCESSOR_NAME(Float_Window) = 0,
    PROCESSOR_NAME(Logger),
    PROCESSOR_NAME(Persistence),
    PROCESSOR_NAME(Upload)
};
