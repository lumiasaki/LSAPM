//
//  LSCPURecorder.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/5.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSCPURecorder.h"
#import <mach/mach_host.h>

@implementation LSCPURecorder

#pragma mark - Internal Functions

ls_cpu_usage_t ls_current_app_cpu_usage() {
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_basic_info_t basic_info_th;
    
    // get threads in the task
    kern_return_t kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    
    if (kr != KERN_SUCCESS) {
        return LS_CPU_USAGE_FAILURE;
    }
    
    ls_cpu_usage_t tot_cpu = 0;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    for (int i = 0; i < thread_count; i++) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[i], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return LS_CPU_USAGE_FAILURE;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
    }
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

ls_cpu_usage_t ls_current_app_cpu_usage_attach_with_thread(thread_t *thread) {
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_basic_info_t basic_info_th;
    
    // get threads in the task
    kern_return_t kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    
    if (kr != KERN_SUCCESS) {
        return LS_CPU_USAGE_FAILURE;
    }
    
    ls_cpu_usage_t tot_cpu = 0;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_t highest = thread_list[0];;
    double highestUsage = 0;
    
    for (int i = 0; i < thread_count; i++) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[i], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return LS_CPU_USAGE_FAILURE;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            float threadUsage = basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
            
            tot_cpu = tot_cpu + threadUsage;
            
            if ((basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100) > highestUsage) {
                highestUsage = basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100;
                
                highest = thread_list[i];
            }
        }
    }
    
    *thread = highest;
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

@end
