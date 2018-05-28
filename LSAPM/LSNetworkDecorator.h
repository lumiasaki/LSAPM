//
//  LSNetworkDecorator.h
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/25.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LSNetworkModule;

@protocol LSNetworkRequestDecorator <NSObject>

@required
@property (nonatomic, weak) LSNetworkModule *networkModule;

@optional
// because the network module will keep a strong reference to the decorator instance, this method should be pure function strongly recommend
// this method is designed as an instance method just for more flexablility
- (NSURLRequest *)canonicalRequest:(NSURLRequest *)request;

@end

@protocol LSNetworkResponseDecorator <NSObject>

@end
