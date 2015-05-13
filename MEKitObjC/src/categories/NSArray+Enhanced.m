//
//  NSArray+Enhanced.m
//  MEKitObjC
//
//  Created by Masayoshi Ukida on 2014/05/22.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import "NSArray+Enhanced.h"
#import "NSDictionary+Enhanced.h"

@implementation NSArray (Enhanced)
- (NSArray*)arrayByRemovingNSNull
{
    return [self arrayByRemovingNSNullRecursively:YES];
}

- (NSArray*)arrayByRemovingNSNullRecursively:(BOOL)recursive
{
    NSMutableArray *array = [self mutableCopy];
    
    for (id object in self) {
        if (object == [NSNull null]) {
            [array removeObject:object];
        }
        
        if (recursive) {
            if ([object isKindOfClass:[NSDictionary class]]) {
                NSInteger index = [array indexOfObject:object];
                NSDictionary *subdictionary = [object dictionaryByRemovingNSNullRecursively:YES];
                [array replaceObjectAtIndex:index withObject:subdictionary];
            }
            else if ([object isKindOfClass:[NSArray class]]) {
                NSInteger index = [array indexOfObject:object];
                NSArray *subarray = [object arrayByRemovingNSNullRecursively:YES];
                [array replaceObjectAtIndex:index withObject:subarray];
            }
        }
    }
    
    return [array copy];
}

@end
