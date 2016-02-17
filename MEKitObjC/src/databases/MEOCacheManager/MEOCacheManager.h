//
//  MEOCacheManager.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/01/23.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef void (^MEOCacheManagerCompletion) (NSData *data, NSDate *createdAt, NSDate *updatedAt);

@interface MEOCacheManager : NSObject

+ (NSData*)dataForKey:(NSString *)key;
+ (NSData*)dataForKey:(NSString *)key completion:(MEOCacheManagerCompletion)completion;

+ (UIImage*)imageForKey:(NSString *)key;
+ (UIImage*)imageForKey:(NSString *)key completion:(MEOCacheManagerCompletion)completion;

+ (NSString*)stringForKey:(NSString *)key;
+ (NSString*)stringForKey:(NSString *)key completion:(MEOCacheManagerCompletion)completion;

+ (void)setData:(NSData *)data forKey:(NSString *)key;
+ (void)setImage:(UIImage *)image forKey:(NSString *)key;
+ (void)setString:(NSString *)string forKey:(NSString *)key;

/**
 *  有効期限付きでデータをキャッシュに保存する
 *
 *  @param data          保存されるデータ
 *  @param validatedDays 有効期限（日）
 *  @param key           キャッシュキー
 */
+ (void)setData:(NSData *)data
  validatedDays:(NSTimeInterval)validatedDays
         forKey:(NSString *)key;

/**
 *  有効期限付きで画像データをキャッシュに保存する
 *
 *  @param image          保存される画像データ
 *  @param validatedDays 有効期限（日）
 *  @param key           キャッシュキー
 */
+ (void)setImage:(UIImage *)image
  validatedDays:(NSTimeInterval)validatedDays
         forKey:(NSString *)key;

/**
 *  有効期限付きで文字データをキャッシュに保存する
 *
 *  @param string        保存される文字データ
 *  @param validatedDays 有効期限（日）
 *  @param key           キャッシュキー
 */
+ (void)setString:(NSString *)string
   validatedDays:(NSTimeInterval)validatedDays
          forKey:(NSString *)key;

+ (void)deleteForKey:(NSString *)key;
+ (void)clearMemoryCache;
+ (void)deleteAllCacheFiles;

+ (NSString*)stringFromData:(NSData*)data;
+ (UIImage*)imageFromData:(NSData*)data;

+ (void)setValidatedDays:(NSTimeInterval)validatedDays;



@end
