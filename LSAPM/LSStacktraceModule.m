//
//  LSStacktraceModule.m
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/17.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSStacktraceModule.h"
#import "LSStacktraceResponseType.h"
#import "BSBacktraceLogger.h"
#import <mach/mach.h>

LSMonitor(LSStacktraceModule)

@interface BSBacktraceLogger (Private)

+ (NSString *)_bs_backtraceOfMachThread:(thread_t)thread;

@end

@implementation LSStacktraceModule

@synthesize monitorManager = _monitorManager;

+ (NSString *)moduleIdentifier {
    return kLSStacktraceMonitorIdentifier;
}

+ (Class)dataModelClass {
    return LSStacktraceDataModel.class;
}

- (void)start {}
- (void)stop {}

- (void)responseForMessage:(NSDictionary *)msg response:(void (^)(id))response {
    if (!response) {
        return;
    }
    
    NSInteger requestType = [msg[LS_MODULE_SECTION_REQUEST_TYPE] unsignedIntegerValue];
    
    switch (requestType) {
        case MainThreadStacktrace:
        {
            LSStacktraceDataModel *model = [[LSStacktraceDataModel alloc] initWithBuilder:^(LSStacktraceDataBuilder *builder) {
                builder.stacktrace = [BSBacktraceLogger bs_backtraceOfMainThread];
            }];
            
            response(model);
            
            break;
        }
        case SpecificThreadStacktrace:
        {
            NSNumber *thread = msg[@"thread"];
            
            if (thread) {
                thread_t thread = [msg[@"thread"] unsignedIntValue];
                
                LSStacktraceDataModel *model = [[LSStacktraceDataModel alloc] initWithBuilder:^(LSStacktraceDataBuilder *builder) {
                    builder.stacktrace = [BSBacktraceLogger _bs_backtraceOfMachThread:thread];
                }];
                
                response(model);
                
                break;
            }
            
            // may be failure
            response(nil);
        }
        default:
            response(nil);
            break;
    }

}

@end
