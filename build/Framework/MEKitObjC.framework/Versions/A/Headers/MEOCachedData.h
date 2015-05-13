//
//  CachedData.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/01/11.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface MEOCachedData : NSObject

//+(NSData*)dataForKey:(NSString *)key;
//+(UIImage*)imageForKey:(NSString *)key;
//
//+(void)setData:(NSData *)data forKey:(NSString *)key;
//+(void)setImage:(UIImage *)image forKey:(NSString *)key;
//+(void)deleteDataForKey:(NSString *)key;
//
//+(void)clearMemoryCache;
//+(void)deleteAllCacheFiles;
//
//// 以下は削除予定

+(MEOCachedData *)sharedInstance;
-(NSData*)cachedDataWithURL:(NSString *)urlString;
-(void)store:(NSData *)data URL:(NSString *)urlString;
-(void)deleteCachedDataWithUrl:(NSString *)urlString;
-(void)clearMemoryCache;
-(void)deleteAllCacheFiles;

@end
