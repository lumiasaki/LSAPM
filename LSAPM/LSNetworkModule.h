//
//  LSNetworkModule.h
//  LSAPM
//
//  Created by Lumia_Saki on 2017/4/24.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSNetworkDecorator.h"
#import "LSNetworkAnalyzer.h"
#import "LSMonitorModule.h"

@class LSNetworkBasicRecordModel;

@interface LSNetworkModule : NSObject<LSMonitorModule>

// !!!set them in addtionalStepsToModule block!!!
@property (nonatomic, strong) id<LSNetworkRequestDecorator> requestDecorator;   //default is nil
@property (nonatomic, strong) id<LSNetworkResponseDecorator> responseDecorator; //default is nil
@property (nonatomic, strong) id<LSNetworkAnalyzer> networkAnalysisProcessor;

- (void)record:(LSNetworkBasicRecordModel *)recordModel;

@end
