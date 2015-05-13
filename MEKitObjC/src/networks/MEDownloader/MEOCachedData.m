//
//  CachedObject.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/01/11.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOCachedData.h"
#import <CommonCrypto/CommonDigest.h>


#define CACHE_DIR @"CACHE_CachedData"

@interface NSData (cashedData)

-(UIImage*)image;

@end

@implementation NSData (cashedData)

-(UIImage*)image
{
    return [UIImage imageWithData:self];
}

@end

@interface NSString (MD5)
-(NSString *)MD5;
@end

@implementation NSString (MD5)

-(NSString *)MD5
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end

@interface MEOCachedData ()
{
    NSCache *cache_;
    NSFileManager *fileManager_;
    NSString *pathCacheDirectory_;
}

-(NSString *)pathForUrl:(NSString *)urlString;
-(void)createDirectories;
-(void)didReceiveMemoryWarning:(NSNotification *)notification;

@end

@implementation MEOCachedData

+ (MEOCachedData *)sharedInstance
{
    static MEOCachedData *sharedInstance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[MEOCachedData alloc] init];
    });
    return sharedInstance;
}

-(id)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
        cache_ = [[NSCache alloc] init];
        cache_.countLimit = 20;
        
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
//                                                             NSUserDomainMask,
//                                                             YES);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                             NSUserDomainMask,
                                                             YES);
        pathCacheDirectory_ = [[paths objectAtIndex:0] stringByAppendingPathComponent:CACHE_DIR];
        
        fileManager_ = [[NSFileManager alloc] init];
        [self createDirectories];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    cache_ = nil;
    fileManager_ = nil;
    pathCacheDirectory_ = nil;
}

-(void)didReceiveMemoryWarning:(NSNotification *)notification
{
    [self clearMemoryCache];
}


-(void)createDirectories
{
    BOOL isDirectory = NO;
    BOOL exists = [fileManager_ fileExistsAtPath:pathCacheDirectory_
                                    isDirectory:&isDirectory];
    if (!exists || !isDirectory) {
        [fileManager_ createDirectoryAtPath:pathCacheDirectory_
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:nil];
    }
    
    for (int i = 0; i < 16; i++) {
        for (int j = 0; j < 16; j++) {
            NSString *subDir =
            [NSString stringWithFormat:@"%@/%x%x", pathCacheDirectory_, i, j];
            
            BOOL isDir = NO;
            BOOL existsSubDir = [fileManager_ fileExistsAtPath:subDir isDirectory:&isDir];
            if (!existsSubDir || !isDir) {
                [fileManager_ createDirectoryAtPath:subDir
                        withIntermediateDirectories:YES
                                         attributes:nil
                                              error:nil];
            }
        }
    }
}

- (void)clearMemoryCache
{
    [cache_ removeAllObjects];
}

- (void)deleteAllCacheFiles
{
    [cache_ removeAllObjects];
    
    if ([fileManager_ fileExistsAtPath:pathCacheDirectory_]) {
        if ([fileManager_ removeItemAtPath:pathCacheDirectory_ error:nil]) {
            [self createDirectories];
        }
    }
    
    BOOL isDirectory = NO;
    BOOL exists = [fileManager_ fileExistsAtPath:pathCacheDirectory_ isDirectory:&isDirectory];
    if (!exists || !isDirectory) {
        [fileManager_ createDirectoryAtPath:pathCacheDirectory_
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:nil];
    }
}


-(NSString *)pathForUrl:(NSString *)urlString
{
    NSString *md5 = [urlString MD5];
    
    NSString *path = [pathCacheDirectory_ stringByAppendingPathComponent:[md5 substringToIndex:2]];
    path = [path stringByAppendingPathComponent:md5];
    
    return path;
}


-(NSData*)cachedDataWithURL:(NSString *)urlString
{
    NSData *cachedData = nil;
    cachedData = [cache_ objectForKey:[urlString MD5]];
    if (!cachedData) {
        cachedData = [NSData dataWithContentsOfFile:[self pathForUrl:urlString]];        
    }
    return cachedData;
}


-(void)store:(NSData *)data URL:(NSString *)urlString
{
    if (data) {
        [cache_ setObject:data forKey:[urlString MD5]];
        [data writeToFile:[self pathForUrl:urlString]
               atomically:YES];        
    }
    
}

-(void)deleteCachedDataWithUrl:(NSString *)urlString
{
    [cache_ removeObjectForKey:[urlString MD5]];
    if ([fileManager_ fileExistsAtPath:[self pathForUrl:urlString]]) {
        [fileManager_ removeItemAtPath:[self pathForUrl:urlString] error:nil];
    }
}

+(NSData*)dataForKey:(NSString *)key{
    MEOCachedData *cd = [MEOCachedData sharedInstance];
    return [cd cachedDataWithURL:key];
}

+(UIImage*)imageForKey:(NSString *)key{
    UIImage *image = nil;
    MEOCachedData *cd = [MEOCachedData sharedInstance];
    NSData *data = [cd cachedDataWithURL:key];
    if (data) {
        image = [UIImage imageWithData:data];
    }
    return image;
}

+(void)setData:(NSData *)data forKey:(NSString *)key{
    MEOCachedData *cd = [MEOCachedData sharedInstance];
    [cd store:data URL:key];
}

+(void)setImage:(UIImage *)image forKey:(NSString *)key{
    MEOCachedData *cd = [MEOCachedData sharedInstance];
    [cd store:UIImagePNGRepresentation(image) URL:key];
}

+(void)deleteDataForKey:(NSString *)key{
    MEOCachedData *cd = [MEOCachedData sharedInstance];
    [cd deleteCachedDataWithUrl:key];
}

+(void)clearMemoryCache{
    MEOCachedData *cd = [MEOCachedData sharedInstance];
    [cd clearMemoryCache];
}

+(void)deleteAllCacheFiles{
    MEOCachedData *cd = [MEOCachedData sharedInstance];
    [cd deleteAllCacheFiles];
}


@end

