//
//  _LSPersistenceDataItemCount.m
//  LSAPM
//
//  Created by tianren.zhu on 2017/5/18.
//  Copyright © 2017年 tianren.zhu. All rights reserved.
//

#import "_LSPersistenceDataItemCount.h"
#import "LSPersistenceConfiguration.h"
#import "LSDictionaryConvertable.h"

// !!! thread-safe provided by LSPersistenceProcessor !!!
// !!! thread-safe provided by LSPersistenceProcessor !!!
// !!! thread-safe provided by LSPersistenceProcessor !!!

static NSString *const prefix = @"lsapm_pending_file";

@interface _LSPersistenceDataItemCount ()

@property (nonatomic, strong) NSMutableArray<LSDataPassToProcessorModel *> *pendings;

@end

@implementation _LSPersistenceDataItemCount
@synthesize delegate = _delegate;
@synthesize configuration = _configuration;

- (void)receiveData:(LSDataPassToProcessorModel *)data {
    if (!data) {
        return;
    }
    
    [self addPendingData:data];
}

// !!!NOT THREAD SAFE!!!
- (NSArray<NSDictionary *> *)persistedData {
    return convertPersistedFileDirsToDictionary(searchAllPersistedFiles());
}

// !!!NOT THREAD SAFE!!!
- (void)purgeData:(NSArray<NSDictionary *> *)toBePurgedData {
    for (NSDictionary *data in toBePurgedData) {
        NSString *fullPath = data[@"fileName"];
        
        [self removeFileSync:fullPath];
    }
}

#pragma mark - Private

static NSArray<NSString *> *searchAllPersistedFiles() {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (NSString *fileName in allFilesAtPath(cacheDir)) {
        if ([fileName hasPrefix:prefix]) {
            [result addObject:fileName];
        }
    }
    
    return result.copy;
}

static NSArray<NSString *> *allFilesAtPath(NSString *path) {
    NSMutableArray *pathArray = [NSMutableArray array];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for (NSString *fileName in [fileManager contentsOfDirectoryAtPath:path error:nil]) {
        BOOL flag = YES;
        NSString *fullPath = [path stringByAppendingPathComponent:fileName];
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&flag]) {
            if (!flag) {
                // ignore .DS_Store
                if (![[fileName substringToIndex:1] isEqualToString:@"."]) {
                    [pathArray addObject:fullPath];
                }
            }
            else {
                [pathArray addObjectsFromArray:allFilesAtPath(fullPath)];
            }
        }
    }
    
    return pathArray.copy;
}

static NSArray<NSDictionary *> *convertPersistedFileDirsToDictionary(NSArray<NSString *> *dirs) {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (NSString *fullPath in dirs) {
        NSArray<LSDataPassToProcessorModel *> *models = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
        
        if ([models isKindOfClass:NSArray.class] && models.count > 0) {
            [result addObject:@{@"data": models,
                                @"fileName": fullPath}];
        }
    }
    
    return result.copy;
}

// !!!NOT THREAD SAFE!!!
- (void)addPendingData:(LSDataPassToProcessorModel *)data {
    if (!data) {
        return;
    }
    
    [self.pendings addObject:data];
    
    [self saveToFilesSyncIfNeeded];
}

- (void)saveToFilesSyncIfNeeded {
    if (self.pendings.count >= self.configuration.pendingItemCount.unsignedIntegerValue) {
        static const NSUInteger SaveFileRetryTime = 3;
        
        BOOL saveSuccessfully = NO;        
        for (NSUInteger i = 0; i < SaveFileRetryTime; i++) {
            if ([self writeToFile:self.distributeAnAvailableFilePath data:self.pendings]) {
                [self.delegate finishPersisting];
                
                saveSuccessfully = YES;
                break;
            }
        }
        
        if (!saveSuccessfully && [self.delegate respondsToSelector:@selector(sendDirectlyInEmergencyCase:)]) {
            [self.delegate sendDirectlyInEmergencyCase:@[@{@"data": [[NSArray alloc] initWithArray:self.pendings.copy],
                                                           @"fileName": [NSNull null]}]];
        }
        
        // if save successfully, remove all objects saved in array
        [self.pendings removeAllObjects];
    }
}

- (BOOL)writeToFile:(NSString *)path data:(NSArray<id<NSCoding>> *)data {
    if (![data isKindOfClass:NSArray.class]) {
        return NO;
    }
    
    return [NSKeyedArchiver archiveRootObject:data toFile:path];
}

- (void)removeFileSync:(NSString *)dir {
    if ([[NSFileManager defaultManager] fileExistsAtPath:dir]) {
        [[NSFileManager defaultManager] removeItemAtPath:dir error:nil];
    }
}

- (NSString *)distributeAnAvailableFilePath {
    static NSUInteger uniqueID = 0;
    
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    BOOL pathIsAvailable = NO;
    NSString *result = nil;
    
    // use case for restart app, unique id start from 0 again, but there was a file already existed.
    do {
        NSString *fileName = [NSString stringWithFormat:@"/%@%lu.dat", prefix, (unsigned long)uniqueID++];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[cacheDir stringByAppendingString:fileName]]) {
            pathIsAvailable = YES;
            
            result = [cacheDir stringByAppendingString:fileName];
        }
    } while (!pathIsAvailable);
    
    return result;
}

#pragma mark - Getter

- (NSMutableArray<LSDataPassToProcessorModel *> *)pendings {
    if (!_pendings) {
        _pendings = [[NSMutableArray alloc] init];
    }
    
    return _pendings;
}

@end
