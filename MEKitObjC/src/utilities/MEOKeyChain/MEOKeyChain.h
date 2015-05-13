//
//  MEOKeyChain.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2014/11/07.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MEOKeyChain : NSObject

+(BOOL)isFirstBoot;

+(BOOL)setData:(NSData*)data forKey:(NSString*)key;
+(BOOL)setString:(NSString*)string forKey:(NSString*)key;

+(NSData*)dataForKey:(NSString*)key;
+(NSString*)stringForKey:(NSString*)key;

+(BOOL)deleteForKey:(NSString*)key;
+(BOOL)clear;
+(BOOL)clearIfFirstBoot;


@end
