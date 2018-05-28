//
//  LSMemoryRecorder.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/6.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSMemoryRecorder.h"
#import <mach/vm_statistics.h>
#import <mach/mach_host.h>
#import <mach/mach_types.h>
#import <mach/task.h>

#if defined(__LP64__)

#define LS_VM_STATISTICS vm_statistics64
#define LS_HOST_STATISTICS_DATA_T vm_statistics64_data_t
#define LS_HOST_VM_INFO_COUNT HOST_VM_INFO64_COUNT
#define LS_HOST_STATISTICS host_statistics64
#define LS_HOST_INFO_T host_info64_t

#else

#define LS_VM_STATISTICS vm_statistics
#define LS_HOST_STATISTICS_DATA_T vm_statistics_data_t
#define LS_HOST_VM_INFO_COUNT HOST_VM_INFO_COUNT
#define LS_HOST_STATISTICS host_statistics
#define LS_HOST_INFO_T host_info_t

#endif

@implementation LSMemoryRecorder

#pragma mark - Internal Functions

__unused static BOOL mem_usage(unsigned int *active, unsigned int *inactive, unsigned int *wired, unsigned int *free) {
    LS_HOST_STATISTICS_DATA_T info = statistics_info();
    
    *active = (unsigned int)info.active_count * PAGE_SIZE;
    *inactive = (unsigned int)info.inactive_count * PAGE_SIZE;
    *wired = (unsigned int)info.wire_count * PAGE_SIZE;
    *free = (unsigned int)info.free_count * PAGE_SIZE;
    
    return YES;
}

BOOL application_mem_usage(double *used) {
    mach_task_basic_info_data_t info;
    mach_msg_type_number_t count = MACH_TASK_BASIC_INFO_COUNT;
    
    kern_return_t kr = task_info(mach_task_self_, MACH_TASK_BASIC_INFO, (task_info_t)&info, &count);
    
    if (kr != KERN_SUCCESS) {
        return NO;
    }
    
    *used = info.resident_size / (1024.0 * 1024.0);
    
    return YES;
}

static struct LS_VM_STATISTICS statistics_info() {
    LS_HOST_STATISTICS_DATA_T data_info;
    mach_msg_type_number_t count = LS_HOST_VM_INFO_COUNT;
    
    kern_return_t kr = LS_HOST_STATISTICS(mach_task_self_, HOST_BASIC_INFO, (LS_HOST_INFO_T)&data_info, &count);
    
    if (kr != KERN_SUCCESS) {
        NSLog(@"GET STATISTICS INFO FAIL");
    }
    
    return data_info;
}

@end
