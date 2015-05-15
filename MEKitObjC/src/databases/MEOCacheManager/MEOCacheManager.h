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

+(NSData*)dataForKey:(NSString *)key;
+(NSData*)dataForKey:(NSString *)key completion:(MEOCacheManagerCompletion)completion;

+(UIImage*)imageForKey:(NSString *)key;
+(UIImage*)imageForKey:(NSString *)key completion:(MEOCacheManagerCompletion)completion;

+(NSString*)stringForKey:(NSString *)key;
+(NSString*)stringForKey:(NSString *)key completion:(MEOCacheManagerCompletion)completion;

+(void)setData:(NSData *)data forKey:(NSString *)key;
+(void)setImage:(UIImage *)image forKey:(NSString *)key;
+(void)setString:(NSString *)string forKey:(NSString *)key;

+(void)deleteForKey:(NSString *)key;
+(void)clearMemoryCache;
+(void)deleteAllCacheFiles;

+(NSString*)stringFromData:(NSData*)data;
+(UIImage*)imageFromData:(NSData*)data;

+(void)setValidatedDays:(NSTimeInterval)validatedDays;



@end
