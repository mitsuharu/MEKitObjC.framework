//
//  MEOCacheManager.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/01/23.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class MEOCache;

typedef NS_ENUM(NSInteger, MEOCacheManagerImageFormat) {
    MEOCacheManagerImageFormatPNG,
    MEOCacheManagerImageFormatJPEG,
};

typedef NS_ENUM(NSInteger, MEOCacheManagerExpires) {
    MEOCacheManagerExpiresNone,
    MEOCacheManagerExpiresOneDay,
    MEOCacheManagerExpiresOneWeek,
    MEOCacheManagerExpiresOneMonth,
};

@interface MEOCacheManager : NSObject

+ (MEOCache*)cacheForKey:(NSString *)key;
+ (NSData*)dataForKey:(NSString *)key;
+ (UIImage*)imageForKey:(NSString *)key;
+ (NSString*)stringForKey:(NSString *)key;

+ (void)setData:(NSData *)data forKey:(NSString *)key;
+ (void)setImage:(UIImage *)image forKey:(NSString *)key;
+ (void)setString:(NSString *)string forKey:(NSString *)key;

/**
 *  有効期限付きでデータをキャッシュに保存する
 */
+ (void)setData:(NSData *)data
         forKey:(NSString *)key
        expires:(MEOCacheManagerExpires)expires;

/**
 *  有効期限付きでデータをキャッシュに保存する
 */
+ (void)setData:(NSData *)data
         forKey:(NSString *)key
    expiresDays:(NSTimeInterval)days;


/**
 *  有効期限付きで画像データをキャッシュに保存する
 */
+ (void)setImage:(UIImage *)image
          forKey:(NSString *)key
         expires:(MEOCacheManagerExpires)expires;

/**
 *  有効期限付きで画像データをキャッシュに保存する
 */
+ (void)setImage:(UIImage *)image
          forKey:(NSString *)key
     expiresDays:(NSTimeInterval)days;

/**
 *  有効期限付きで文字データをキャッシュに保存する
 */
+ (void)setString:(NSString *)string
           forKey:(NSString *)key
          expires:(MEOCacheManagerExpires)expires;

/**
 *  有効期限付きで文字データをキャッシュに保存する
 */
+ (void)setString:(NSString *)string
           forKey:(NSString *)key
      expiresDays:(NSTimeInterval)days;


+ (void)deleteForKey:(NSString *)key;
+ (void)clearMemoryCache;
+ (void)deleteAllCacheFiles;

+ (NSString*)stringFromData:(NSData*)data;
+ (UIImage*)imageFromData:(NSData*)data;

+ (void)setExpiresDays:(NSTimeInterval)expiresDays;

+ (void)setImageFotmart:(MEOCacheManagerImageFormat)imageFormart;

+ (void)deleteExpiredCacheFiles:(MEOCacheManagerExpires)exprire;

@end
