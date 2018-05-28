//
//  QLSAPMConfiguration.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/26.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "LSAPMConfiguration.h"
#import "QLSDataUploadConfiguration.h"

@interface QLSAPMConfiguration : LSAPMConfiguration

@property (nonatomic, strong) NSString *pid;
@property (nonatomic, strong) NSString *cid;
@property (nonatomic, strong) NSString *vid;
@property (nonatomic, strong) NSString *uid;

@property (nonatomic, strong) QLSDataUploadConfiguration *dataUploadConfiguration;

@end
