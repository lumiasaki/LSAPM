//
//  LSCPURecorder.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/5.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach.h>

typedef double ls_cpu_usage_t;

#define LS_CPU_USAGE_FAILURE (ls_cpu_usage_t)-1

FOUNDATION_EXPORT ls_cpu_usage_t ls_current_app_cpu_usage();
FOUNDATION_EXPORT ls_cpu_usage_t ls_current_app_cpu_usage_attach_with_thread(thread_t *thread);

@interface LSCPURecorder : NSObject

@end
