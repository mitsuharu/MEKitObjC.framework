//
//  MEOCacheManager.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/01/23.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOCacheManager.h"
#import "MEOCache.h"

#import <CommonCrypto/CommonDigest.h>
#define CACHE_DIR @"CACHE_MEOCacheManager"

@interface NSString (MD5)
- (NSString *)MD5;
@end

@implementation NSString (MD5)

- (NSString *)MD5
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

@interface MEOCacheManager ()
{
    NSCache *cache_;
    NSFileManager *fileManager_;
    NSString *pathCacheDirectory_;
    
    NSTimeInterval expiresDays_;
}

+ (MEOCacheManager*)sharedInstance;

- (NSString *)pathForUrl:(NSString *)urlString;
- (void)createDirectories;
- (void)didReceiveMemoryWarning:(NSNotification *)notification;

- (void)clearMemoryCache;
- (void)deleteAllCacheFiles;

- (MEOCache*)dataForKey:(NSString *)key;
- (void)setData:(NSData *)data forKey:(NSString *)key;
- (void)deleteCachedDataWithUrl:(NSString *)urlString;

- (void)setExpiresDays:(NSTimeInterval)expiresDays;

@end

@implementation MEOCacheManager

+ (MEOCacheManager*)sharedInstance
{
    static MEOCacheManager *sharedInstance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[MEOCacheManager alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
        cache_ = [[NSCache alloc] init];
        cache_.countLimit = 20;
        
        expiresDays_ = -1.0;
        
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    cache_ = nil;
    fileManager_ = nil;
    pathCacheDirectory_ = nil;
}

- (void)didReceiveMemoryWarning:(NSNotification *)notification
{
    [self clearMemoryCache];
}

- (void)setExpiresDays:(NSTimeInterval)expiresDays
{
    expiresDays_ = expiresDays;
}

- (NSTimeInterval)elapsedDays:(NSDate*)basedDate
{
    NSTimeInterval days = 0.0;
    if (basedDate) {
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:basedDate];
        days = (interval / (24.0*60.0*60.0));
    }
    return days;
}


- (void)createDirectories
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


- (NSString *)pathForUrl:(NSString *)urlString
{
    NSString *md5 = [urlString MD5];
    
    NSString *path = [pathCacheDirectory_ stringByAppendingPathComponent:[md5 substringToIndex:2]];
    path = [path stringByAppendingPathComponent:md5];
    
    return path;
}


- (MEOCache*)dataForKey:(NSString *)key
{
    MEOCache *cachedData = [cache_ objectForKey:[key MD5]];
    if (cachedData == nil) {
        cachedData = [MEOCache cacheWithFile:[self pathForUrl:key]];
    }
    
    // 有効期限
    NSTimeInterval tempExpiresDays = expiresDays_;
    if (cachedData.expiresDays > 0) {
        tempExpiresDays = cachedData.expiresDays;
    }
    if (tempExpiresDays > 0 && cachedData.updatedAt) {
        NSTimeInterval diff = [self elapsedDays:cachedData.updatedAt];
        if (diff > tempExpiresDays) {
            cachedData = nil;
            [self deleteCachedDataWithUrl:key];
        }
    }
    
    return cachedData;
}

- (void)setData:(NSData *)data
         forKey:(NSString *)key
    expiresDays:(NSTimeInterval )days
{
    if (data && key) {
        MEOCache *tempCache = [self dataForKey:key];
        if (tempCache) {
            tempCache.data = data;
            tempCache.updatedAt = [NSDate date];
        }else{
            tempCache = [[MEOCache alloc] initWithData:data];
        }
        tempCache.expiresDays = days;
        [cache_ setObject:tempCache forKey:[key MD5]];
        [tempCache writeToFile:[self pathForUrl:key]];
    }
}

- (void)setData:(NSData *)data forKey:(NSString *)key
{
    [self setData:data forKey:key expiresDays:0];
}

- (void)deleteCachedDataWithUrl:(NSString *)urlString
{
    [cache_ removeObjectForKey:[urlString MD5]];
    if ([fileManager_ fileExistsAtPath:[self pathForUrl:urlString]]) {
        [fileManager_ removeItemAtPath:[self pathForUrl:urlString] error:nil];
    }
}


#pragma mark - 公開用のメソッド

+ (void)setExpiresDays:(NSTimeInterval)expiresDays
{
    MEOCacheManager *cm = [MEOCacheManager sharedInstance];
    [cm setExpiresDays:expiresDays];
}


+ (NSData*)dataForKey:(NSString *)key
{
    return [MEOCacheManager dataForKey:key
                            completion:nil];
}

+ (NSData*)dataForKey:(NSString *)key completion:(MEOCacheManagerCompletion)completion
{
    MEOCacheManager *cm = [MEOCacheManager sharedInstance];
    MEOCache *cache = [cm dataForKey:key];
    
    NSData *data = nil;
    NSDate *createdAt = nil;
    NSDate *updatedAt = nil;
    if (cache) {
        data = cache.data;
        createdAt = cache.createdAt;
        updatedAt = cache.updatedAt;
    }
    
    if (completion) {
        completion(data, createdAt, updatedAt);
    }
    return data;
}

+ (UIImage*)imageForKey:(NSString *)key
{
    return [MEOCacheManager imageForKey:key completion:nil];
}

+ (UIImage*)imageForKey:(NSString *)key completion:(MEOCacheManagerCompletion)completion
{
    NSData *data = [MEOCacheManager dataForKey:key completion:completion];
    UIImage *image = nil;
    if (data) {
        image = [UIImage imageWithData:data];
    }
    return image;
}

+ (NSString*)stringForKey:(NSString *)key
{
    return [MEOCacheManager stringForKey:key completion:nil];
}

+ (NSString*)stringForKey:(NSString *)key completion:(MEOCacheManagerCompletion)completion
{
    NSData *data = [MEOCacheManager dataForKey:key completion:completion];
    NSString *string = nil;
    if (data) {
        string = [MEOCache stringFromData:data];
    }
    return string;
}

+ (NSString*)stringFromData:(NSData*)data
{
    return [MEOCache stringFromData:data];
}

+ (UIImage*)imageFromData:(NSData*)data
{
    return [UIImage imageWithData:data];
}

+ (NSTimeInterval)daysFormExpires:(MEOCacheManagerExpires)expires
{
    NSTimeInterval days = 0;
    
    if (expires == MEOCacheManagerExpiresNone) {
    }else if (expires == MEOCacheManagerExpiresOneDay){
        days = 1;
    }else if (expires == MEOCacheManagerExpiresOneWeek){
        days = 7;
    }else if (expires == MEOCacheManagerExpiresOneMonth){
        days = 30;
    }
    
    return days;
}

+ (void)setData:(NSData *)data
         forKey:(NSString *)key
        expires:(MEOCacheManagerExpires)expires
{
    MEOCacheManager *cm = [MEOCacheManager sharedInstance];
    [cm setData:data forKey:key expiresDays:[MEOCacheManager daysFormExpires:expires]];
}

+ (void)setData:(NSData *)data
         forKey:(NSString *)key
    expiresDays:(NSTimeInterval)days
{
    MEOCacheManager *cm = [MEOCacheManager sharedInstance];
    [cm setData:data forKey:key expiresDays:days];
}


+ (void)setData:(NSData *)data forKey:(NSString *)key
{
    MEOCacheManager *cm = [MEOCacheManager sharedInstance];
    [cm setData:data forKey:key];
}


+ (void)setImage:(UIImage *)image
          forKey:(NSString *)key
         expires:(MEOCacheManagerExpires)expires
{
    [MEOCacheManager setData:UIImagePNGRepresentation(image)
                      forKey:key
                 expiresDays:[MEOCacheManager daysFormExpires:expires]];
}

+ (void)setImage:(UIImage *)image
          forKey:(NSString *)key
     expiresDays:(NSTimeInterval)days
{
    [MEOCacheManager setData:UIImagePNGRepresentation(image)
                      forKey:key
                 expiresDays:days];
}

+ (void)setImage:(UIImage *)image forKey:(NSString *)key
{
    [MEOCacheManager setData:UIImagePNGRepresentation(image)
                      forKey:key];
}

+ (void)setString:(NSString *)string
           forKey:(NSString *)key
          expires:(MEOCacheManagerExpires)expires
{
    [MEOCacheManager setData:[MEOCache dataFromString:string]
                      forKey:key
                 expiresDays:[MEOCacheManager daysFormExpires:expires]];
}

/**
 *  有効期限付きで文字データをキャッシュに保存する
 */
+ (void)setString:(NSString *)string
           forKey:(NSString *)key
      expiresDays:(NSTimeInterval)days
{
    [MEOCacheManager setData:[MEOCache dataFromString:string]
                      forKey:key
                 expiresDays:days];
}


+ (void)setString:(NSString *)string forKey:(NSString *)key;
{
    [MEOCacheManager setData:[MEOCache dataFromString:string]
                      forKey:key];
}

+ (void)deleteForKey:(NSString *)key{
    MEOCacheManager *cm = [MEOCacheManager sharedInstance];
    [cm deleteCachedDataWithUrl:key];
}

+ (void)clearMemoryCache{
    MEOCacheManager *cm = [MEOCacheManager sharedInstance];
    [cm clearMemoryCache];
}

+ (void)deleteAllCacheFiles{
    MEOCacheManager *cm = [MEOCacheManager sharedInstance];
    [cm deleteAllCacheFiles];
}


@end














