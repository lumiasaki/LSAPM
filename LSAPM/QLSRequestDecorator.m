//
//  LSRequestDecorator.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/4/25.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "QLSRequestDecorator.h"
#import <CommonCrypto/CommonDigest.h>

#import "LSMonitorManager.h"
#import "LSMonitorModule.h"
#import "LSNetworkModule.h"
#import "LSAPM.h"
#import "QLSAPMConfiguration.h"

@implementation QLSRequestDecorator

@synthesize networkModule = _networkModule;

- (NSURLRequest *)canonicalRequest:(NSURLRequest *)request {
    // 给request的Header添加L-Uuid字段
    NSMutableURLRequest *mutableURLRequest = [request mutableCopy];
    if (mutableURLRequest && [self.networkModule.monitorManager.apm.configuration isKindOfClass:[QLSAPMConfiguration class]]) {
        NSString *aID = [[NSUUID UUID] UUIDString];
        NSString *uID = [(QLSAPMConfiguration *)self.networkModule.monitorManager.apm.configuration uid];
        NSString *L_UuidString = [NSString stringWithFormat:@"%@%@", aID, uID];
        NSString *L_UuidMD5String = [QLSRequestDecorator getStringMD5:L_UuidString];
        if (L_UuidMD5String) {
            [mutableURLRequest addValue:L_UuidMD5String forHTTPHeaderField:@"L-Uuid"];
            
            return [mutableURLRequest copy];
        }
    }
    
    return request;
}

+ (NSString *)getStringMD5:(NSString *)inputString
{
    const char *ptr = [inputString UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];

    CC_MD5(ptr, (unsigned int)strlen(ptr), md5Buffer);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", md5Buffer[i]];
    }

    return [output copy];
}

@end
