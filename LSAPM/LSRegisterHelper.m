//
//  LSRegisterHelper.m
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/14.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSRegisterHelper.h"
#import "LSPriorityable.h"
#import "LSMonitorModule.h"
#import <mach-o/getsect.h>
#import <dlfcn.h>

@implementation LSRegisterHelper

#pragma mark - Public

+ (NSArray<Class> *)allMonitorModules {
    NSArray<id<LSMonitorModule>> *monitorModules = getClassesFromSection(LSMonitorSect);
    
#ifdef DEBUG
    warningIfHasSameModuleIdentifier(monitorModules);
#endif
    
    return monitorModules;
}

+ (NSArray<Class> *)allProcessors {
    NSArray<id<LSPriorityable>> *processors = getClassesFromSection(LSProcessorSect);
    
#ifdef DEBUG
    warningIfHasSamePriority(processors);
#endif
    
    return [processors sortedArrayUsingComparator:^NSComparisonResult(id<LSPriorityable>  _Nonnull first, id<LSPriorityable>  _Nonnull second) {        
        if ([first respondsToSelector:@selector(priority)] && [second respondsToSelector:@selector(priority)]) {
            if ([first priority] < [second priority]) {
                return (NSComparisonResult)NSOrderedDescending;
            } else if ([first priority] > [second priority]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
        }
        
        // should never access here
        return NSOrderedSame;
    }];
}

#pragma mark - Private

static inline void warningIfHasSamePriority(NSArray<id<LSPriorityable>> *processors) {
    for (NSUInteger i = 0; i < processors.count; i++) {
        id<LSPriorityable> processor = processors[i];

        if (![processor respondsToSelector:@selector(priority)]) {
            @throw [NSException exceptionWithName:@"Debug Warning" reason:[NSString stringWithFormat:@"%@ can't respond to priority method", processor] userInfo:nil];
        }
        
        NSUInteger priority = [processor priority];
        
        for (NSUInteger j = i + 1; j < processors.count; j++) {
            id<LSPriorityable> jProcessor = processors[j];

            if (![jProcessor respondsToSelector:@selector(priority)]) {
                @throw [NSException exceptionWithName:@"Debug Warning" reason:[NSString stringWithFormat:@"%@ can't respond to priority method", jProcessor] userInfo:nil];
            }

            NSUInteger jPriority = [jProcessor priority];
            
            if (priority == jPriority) {
                @throw [NSException exceptionWithName:@"Debug Warning" reason:@"processors should have unique priority" userInfo:nil];
            }
        }
    }
}

static inline void warningIfHasSameModuleIdentifier(NSArray<id<LSMonitorModule>> *modules) {
    for (NSUInteger i = 0; i < modules.count; i++) {
        id<LSMonitorModule> monitor = modules[i];
        if (![monitor respondsToSelector:@selector(moduleIdentifier)]) {
            @throw [NSException exceptionWithName:@"Debug Warning" reason:[NSString stringWithFormat:@"%@ can't respond to moduleIdentifier method", monitor] userInfo:nil];
        }
        
        NSString *monitorIdentifier = [monitor moduleIdentifier];
        
        for (NSUInteger j = i + 1; j < modules.count; j++) {
            id<LSMonitorModule> jMonitor = modules[j];
            
            if (![jMonitor respondsToSelector:@selector(moduleIdentifier)]) {
                @throw [NSException exceptionWithName:@"Debug Warning" reason:[NSString stringWithFormat:@"%@ can't respond to moduleIdentifier method", jMonitor] userInfo:nil];
            }
            
            NSString *jMonitorIdentifier = [jMonitor moduleIdentifier];
            
            if ([monitorIdentifier isEqualToString:jMonitorIdentifier]) {
                @throw [NSException exceptionWithName:@"Debug Warning" reason:[NSString stringWithFormat:@"%@ and %@ has same monitor identifier", monitor, jMonitor] userInfo:nil];
            }
        }
    }
}

static NSArray<Class>* getClassesFromSection(char *section) {
    NSArray *classNames = getModulesFromSection(section);
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (NSString *className in classNames) {
        if ([className isKindOfClass:NSString.class]) {
            Class clz = NSClassFromString(className);
            
            if (clz) {
                [result addObject:clz];
            }
#ifdef DEBUG
            else {
                @throw [NSException exceptionWithName:@"Debug Warning" reason:[NSString stringWithFormat:@"%@ can't get Class object", className] userInfo:nil];
            }
#endif
        }
    }
    
    return result.copy;
}

static NSArray<NSString *>* getModulesFromSection(char *section) {
    NSMutableArray *modules = [NSMutableArray array];
    
    Dl_info info;
    dladdr(getModulesFromSection, &info);
#ifndef __LP64__
    const struct mach_header *mh = (struct mach_header*)info.dli_fbase;
    unsigned long size = 0;
    uint32_t *memory = (uint32_t*)getsectiondata(mh, "__DATA", section, &size);
#else
    const struct mach_header_64 *mh = (struct mach_header_64*)info.dli_fbase;
    unsigned long size = 0;
    uint64_t *memory = (uint64_t*)getsectiondata(mh, "__DATA", section, &size);
#endif
    for(int idx = 0; idx < size / sizeof(void*); idx++){
        NSString *str = [NSString stringWithUTF8String:(char*)memory[idx]];
        
        if(str) {
            [modules addObject:str];
        } else {
            continue;
        }
    }
    
    return modules;
}

@end

