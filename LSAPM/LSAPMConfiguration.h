//
//  LSAPMConfiguration.h
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/12.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIView;
@class LSPersistenceConfiguration;

typedef NS_ENUM(NSInteger, LSAPMEnv) {
    Debug,
    Release
};

/**
 * subclass inherits this class, adds other useful informations.
 */
@interface LSAPMConfiguration : NSObject

@property (nonatomic, assign) LSAPMEnv env;
@property (nonatomic, strong) LSPersistenceConfiguration *persistenceConfiguration;

@end

// TODO: 确认qav中是不是已经做了，做了就暂时不要这部分了
//@interface LSAPMConfiguration (ViewControllerTraceViaNavigationController)
//
//@property (nonatomic, strong) UINavigationController *navigationController;
//
//@end

@interface LSAPMConfiguration (FloatingWindow)

@property (nonatomic, strong) UIView *floatingWindowSuperview;

@end
