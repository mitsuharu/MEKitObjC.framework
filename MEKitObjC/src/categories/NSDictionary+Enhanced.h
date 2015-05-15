//
//  NSDictionary+Enhanced.h
//  MEKitObjC
//
//  Created by Masayoshi Ukida on 2014/05/22.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSDictionary (Enhanced)

-(NSDictionary*)dictionaryForKey:(NSString*)key;
-(NSArray*)arrayForKey:(NSString*)key;
-(NSString*)stringForKey:(NSString*)key;
-(NSNumber*)numberForKey:(NSString*)key;
-(NSDate*)dateForKey:(NSString*)key;
-(UIImage*)imageForKey:(NSString*)key;

-(NSInteger)integerForKey:(NSString*)key;
-(BOOL)boolForKey:(NSString*)key;

- (NSDictionary*)dictionaryByRemovingNSNull;
- (NSDictionary*)dictionaryByRemovingNSNullRecursively:(BOOL)recursive;
@end
