//
//  LSMonitorManager.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/10.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSMonitorManager.h"
#import "LSDataProcessManager.h"
#import "LSAPM.h"
#import "LSUtils.h"
#import "LSDeviceInfoRecorder.h"

@interface LSMonitorManager ()

@property (nonatomic, strong) NSMutableSet<id<LSMonitorModule>> *modules;

@end

@implementation LSMonitorManager

#pragma mark - Public

- (void)addMonitorModule:(id<LSMonitorModule>)module {
    NSAssert(module, @"module is nil");
    
    ls_executeOnMonitorQueue(^{
        module.monitorManager = self;
        [self.modules addObject:module];
    }, NO);
}

- (void)removeMonitorModule:(id<LSMonitorModule>)module {
    NSAssert(module, @"module is nil");
    
    ls_executeOnMonitorQueue(^{
        [self.modules removeObject:module];
    }, NO);
}

- (NSSet<id<LSMonitorModule>> *)monitorModules {
    return self.modules.copy;
}

- (void)ready {
    ls_executeOnMonitorQueue(^{
        for (id<LSMonitorModule> module in self.modules) {
            if ([module respondsToSelector:@selector(start)]) {
                [module start];
            }
        }
    }, NO);
}

- (void)stopAll {
    ls_executeOnMonitorQueue(^{
        for (id<LSMonitorModule> module in self.modules) {
            if ([module respondsToSelector:@selector(stop)]) {
                [module stop];
            }
        }
    }, NO);
}

- (void)sendMessage:(NSDictionary *)msg fromModule:(id<LSMonitorModule>)from toModule:(id<LSMonitorModule>)to response:(void(^)(id))response {
    ls_executeOnMonitorQueue(^{
        NSAssert([msg[LS_MODULE_SECTION_REQUEST_TYPE] isKindOfClass:NSNumber.class], @"message which be sent between modules should contains 'LS_MODULE_SECTION_REQUEST_TYPE' key to let the destination module knows what is your demand");
        
        if ([to respondsToSelector:@selector(responseForMessage:response:)] && [from conformsToProtocol:@protocol(LSMonitorModule)]) {
            NSMutableDictionary *appendedMsg = [[NSMutableDictionary alloc] initWithDictionary:msg];
            
            [appendedMsg addEntriesFromDictionary:@{
                                                    @"from": [from.class moduleIdentifier]
                                                    }];
            
            [to responseForMessage:appendedMsg.copy response:^(id res) {
#ifdef DEBUG
                Class cls = [[to class] dataModelClass];
                
                NSAssert(cls == [res class], @"response data model is invalid. %@, %@", cls, [res class]);
#endif
                response(res);
            }];
        }
    }, NO);
}

- (void)sendMessage:(NSDictionary *)msg fromModuleID:(NSString *)fromID toModuleID:(NSString *)toID response:(void (^)(id))response {
    ls_executeOnMonitorQueue(^{
        id<LSMonitorModule> from = [self monitorWithIdentifier:fromID];
        id<LSMonitorModule> to = [self monitorWithIdentifier:toID];
        
        assert(from);
        assert(to);
        
        [self sendMessage:msg fromModule:from toModule:to response:response];
    }, NO);
}


- (id<LSMonitorModule>)monitorWithClassName:(NSString *)className {
    if (!className) {
        return nil;
    }
    
    __block id<LSMonitorModule> result = nil;
    
    [self.monitorModules enumerateObjectsUsingBlock:^(id<LSMonitorModule>  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(className)]) {
            result = obj;
            
            *stop = YES;
        }
    }];
    
    return result;
}

- (id<LSMonitorModule>)monitorWithIdentifier:(NSString *)moduleIdentifier {
    if (!moduleIdentifier) {
        return nil;
    }
    
    __block id<LSMonitorModule> result = nil;
    
    [self.monitorModules enumerateObjectsUsingBlock:^(id<LSMonitorModule>  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([[obj.class moduleIdentifier] isEqualToString:moduleIdentifier]) {
            result = obj;
            
            *stop = YES;
        }
    }];
    
    return result;
}

- (void)sendUnifiedDataToDataProcessor:(LSDataPassToProcessorModel *)data {
    NSAssert(data, @"data pass to processor is nil");
    
    ls_executeOnMonitorQueue(^{
        // record the time
        data.timestamp = [NSDate date];
        
        if (_determineIfAppendDeviceInfo(data.eventName)) {
            [self appendDeviceInfoToData:data];
        }
        
        dispatch_async(LSGetDataProcessManagerQueue(), ^{
            [self.processorManager receive:data];
        });
    }, NO);
}

#pragma mark - Private

static BOOL _determineIfAppendDeviceInfo(NSString *eventName) {
    return ![_DontAppendContent() containsObject:eventName];
}

static inline NSSet *_DontAppendContent() {
    return [NSSet setWithArray:@[
                                 kLSEventNameFPSUpdate
                                 ]
            ];
}

- (void)appendDeviceInfoToData:(LSDataPassToProcessorModel *)data {
    LSDeviceDataModel *device = [[LSDeviceDataModel alloc] initWithBuilder:^(LSDeviceDataModelBuilder *b) {
        b.deviceType = [LSDeviceInfoRecorder deviceType];
        b.OSVersion = [LSDeviceInfoRecorder OSVersion];
        b.screenBrightness = @([LSDeviceInfoRecorder screenBrightness]);
        b.isPluggedIn = @([LSDeviceInfoRecorder deviceIsPluggedIn]);
        b.isJailbreak = @([LSDeviceInfoRecorder isJailbreak]);
        b.batteryLevel = @([LSDeviceInfoRecorder batteryLevel]);
        b.carrier = [LSDeviceInfoRecorder carrier];
        b.networkType = [LSDeviceInfoRecorder networkType];
    }];
    
    data.deviceInfo = device;
}

- (NSMutableSet<id<LSMonitorModule>> *)modules {
    if (!_modules) {
        _modules = [[NSMutableSet alloc] init];
    }
    return _modules;
}

- (LSDataProcessManager *)processorManager {
    return self.apm.processManager;
}

@end
