//
//  NSDictionary+Enhanced.h
//  MEKitObjC
//
//  Created by Masayoshi Ukida on 2014/05/22.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Enhanced)

-(NSString*)stringForKey:(NSString*)key;
-(NSNumber*)numberForKey:(NSString*)key;
-(NSDate*)dateForKey:(NSString*)key;


- (NSDictionary*)dictionaryByRemovingNSNull;
- (NSDictionary*)dictionaryByRemovingNSNullRecursively:(BOOL)recursive;
@end
