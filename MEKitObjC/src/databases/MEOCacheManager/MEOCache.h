//
//  MEOCache.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/01/23.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface MEOCache : NSObject

@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;

/**
 *  有効時間（日）
 */
@property (nonatomic) NSTimeInterval expiration;

-(id)initWithData:(NSData*)data;

-(BOOL)writeToFile:(NSString*)path;
+(MEOCache*)cacheWithFile:(NSString*)path;

-(UIImage*)image;
-(void)setImage:(UIImage*)image;

-(NSString*)string;
-(void)setString:(NSString*)string;

+(NSString*)stringFromData:(NSData*)data;
+(NSData*)dataFromString:(NSString*)string;

@end
