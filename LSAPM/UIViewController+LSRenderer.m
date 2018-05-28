//
//  UIViewController+LSRenderer.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/18.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "UIViewController+LSRenderer.h"
#import "LSViewControllerLoadTimeModule.h"
#import <objc/runtime.h>

static LSViewControllerLoadTimeModule *ls_viewControllerLoadMonitorModule;

static NSMutableDictionary *ls_savedOriginalIMPs;

@implementation UIViewController (LSRenderer)

+ (void)setLs_viewControllerLoadMonitorModule:(LSViewControllerLoadTimeModule *)monitorModule {
    ls_viewControllerLoadMonitorModule = monitorModule;
}

+ (void)ls_startMonitoring {
    NSAssert(ls_viewControllerLoadMonitorModule, @"should assign loadTimeModule before start recording view controllers load time");
    
    // hook life cycle methods
    [self ls_saveOriginalIMPBeforeSwizzleMethod:self original:@selector(viewDidLoad) swzzled:@selector(ls_recordedViewDidLoad)];
    [self ls_saveOriginalIMPBeforeSwizzleMethod:self original:@selector(viewWillAppear:) swzzled:@selector(ls_recordedViewWillAppear:)];
    [self ls_saveOriginalIMPBeforeSwizzleMethod:self original:@selector(viewDidAppear:) swzzled:@selector(ls_recordedViewDidAppear:)];
    
    //TODO:暂时不做记录
//        [self ls_saveOriginalIMPBeforeSwizzleMethod:self original:@selector(viewWillDisappear:) swzzled:@selector(ls_recordedViewWillDisappear:)];
//        [self ls_saveOriginalIMPBeforeSwizzleMethod:self original:@selector(viewDidDisappear:) swzzled:@selector(ls_recordedViewDidDisappear:)];
}

+ (void)ls_invalidate {
    [self ls_restoreAllMethodsToUnswizzleState];
    
    ls_viewControllerLoadMonitorModule = nil;
}

#define LSRecordModelHead() \
LSViewControllerRecordModel *model = [[LSViewControllerRecordModel alloc] initWithViewController:self recordedMethodName:restoreSwizzleMethodName(NSStringFromSelector(_cmd))]; \
model.timestamp = [NSDate date].timeIntervalSince1970; \

#define LSRecordModelTail() \
[ls_viewControllerLoadMonitorModule record:model]; \

#define LSRecordViewControllerLoadNoParameter(method) \
- (void)method { \
LSRecordModelHead() \
[self method]; \
LSRecordModelTail() \
} \

#define LSRecordViewControllerLoadWithSingleParameter(method, paramType) \
- (void)method:(paramType)param { \
LSRecordModelHead() \
[self method:param]; \
LSRecordModelTail() \
} \

#pragma mark - Life-Cycle Methods

LSRecordViewControllerLoadNoParameter(ls_recordedViewDidLoad)
LSRecordViewControllerLoadWithSingleParameter(ls_recordedViewWillAppear, BOOL)
LSRecordViewControllerLoadWithSingleParameter(ls_recordedViewDidAppear, BOOL)

// TODO:暂时不做记录
//LSRecordViewControllerLoadWithSingleParameter(ls_recordedViewWillDisappear, BOOL)
//LSRecordViewControllerLoadWithSingleParameter(ls_recordedViewDidDisappear, BOOL)

#pragma mark - Private

+ (void)ls_saveOriginalIMPBeforeSwizzleMethod:(Class)target original:(SEL)original swzzled:(SEL)swizzled {
    if (!ls_savedOriginalIMPs) {
        ls_savedOriginalIMPs = [[NSMutableDictionary alloc] init];
    }
    
    Method origMethod = class_getInstanceMethod(target, original);
    
    NSString *swizzledName = NSStringFromSelector(swizzled);
    
    if (swizzledName) {
        ls_savedOriginalIMPs[swizzledName] = ^Method(void) {
            return origMethod;
        };
    }
    
    [LSUtils swizzleInstanceMethods:target originalSelector:original swizzledSelector:swizzled];
}

+ (void)ls_restoreAllMethodsToUnswizzleState {
    NSArray *keys = [ls_savedOriginalIMPs allKeys];
    
    for (NSString *swizzledMethodName in keys) {
        Method(^returnMethodBlock)(void) = ls_savedOriginalIMPs[swizzledMethodName];
        
        Method originalMethod = returnMethodBlock();
        
        SEL swizzedMethodSel = NSSelectorFromString(swizzledMethodName);
        
        [LSUtils swizzleInstanceMethods:self originalSelector:swizzedMethodSel swizzledSelector:method_getName(originalMethod)];
    }
    
    [ls_savedOriginalIMPs removeAllObjects];
}

static NSString * restoreSwizzleMethodName(NSString *swizzleMethodName) {
    if (![swizzleMethodName isKindOfClass:NSString.class] || swizzleMethodName.length == 0) {
        return nil;
    }
    
    NSString *firstCharUpperCased = [swizzleMethodName stringByReplacingOccurrencesOfString:@"ls_recorded" withString:@""];
    
    if (firstCharUpperCased.length > 1) {
        NSString *firstChar = [firstCharUpperCased substringToIndex:1];
        
        return [firstChar stringByAppendingString:[firstCharUpperCased substringFromIndex:1]];
    }
    
    return nil;
}

@end

@implementation LSViewControllerRecordModel

- (instancetype)initWithViewController:(UIViewController *)viewController recordedMethodName:(NSString *)methodName; {
    if (self = [super init]) {
        _viewController = viewController;
        _methodName = methodName;
    }
    return self;
}

@end
