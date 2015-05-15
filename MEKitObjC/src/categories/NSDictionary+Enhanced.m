//
//  NSDictionary+Enhanced.m
//  MEKitObjC
//
//  Created by Masayoshi Ukida on 2014/05/22.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDictionary+Enhanced.h"
#import "NSArray+Enhanced.h"

@implementation NSDictionary (Enhanced)

-(id)valueForKey:(NSString*)key className:(NSString*)className
{
    Class vcClass = NSClassFromString(className);
    id value = nil;
    if (key && [self.allKeys containsObject:key]) {
        id obj = [self objectForKey:key];
        if (vcClass && [obj isKindOfClass:vcClass]) {
            value = obj;
        }
    }
    return value;
}

-(NSString*)stringForKey:(NSString*)key
{
    id obj = [self valueForKey:key className:@"NSString"];
    return (NSString*)obj;
}

-(NSNumber*)numberForKey:(NSString*)key
{
    id obj = [self valueForKey:key className:@"NSNumber"];
    return (NSNumber*)obj;
}

-(NSDate*)dateForKey:(NSString*)key
{
    id obj = [self valueForKey:key className:@"NSDate"];
    return (NSDate*)obj;
}

-(NSData*)dataForKey:(NSString*)key
{
    id obj = [self valueForKey:key className:@"NSData"];
    return (NSData*)obj;
}

-(UIImage*)imageForKey:(NSString*)key
{
    id obj = [self valueForKey:key className:@"UIImage"];
    return (UIImage*)obj;
}

-(NSDictionary*)dictionaryForKey:(NSString*)key
{
    id obj = [self valueForKey:key className:@"NSDictionary"];
    return (NSDictionary*)obj;
}

-(NSArray*)arrayForKey:(NSString*)key
{
    id obj = [self valueForKey:key className:@"NSArray"];
    return (NSArray*)obj;
}


-(BOOL)boolForKey:(NSString*)key
{
    NSNumber *num = [self numberForKey:key];
    BOOL result = false;
    if (num) {
        result = [num boolValue];
    }
    return result;
}

-(NSInteger)integerForKey:(NSString*)key
{
    NSNumber *num = [self numberForKey:key];
    NSInteger result = 0;
    if (num) {
        result = [num integerValue];
    }
    return result;
}


- (NSDictionary*)dictionaryByRemovingNSNull
{
    return [self dictionaryByRemovingNSNullRecursively:YES];
}

- (NSDictionary*)dictionaryByRemovingNSNullRecursively:(BOOL)recursive
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self];
    
    for (id key in [self allKeys]) {
        id object = [self objectForKey:key];
        
        if (object == [NSNull null]) {
            [dictionary removeObjectForKey:key];
        }
        
        if (recursive) {
            if ([object isKindOfClass:[NSDictionary class]]) {
                NSDictionary *subdictionary = [object dictionaryByRemovingNSNullRecursively:YES];
                [dictionary setValue:subdictionary forKey:key];
            }
            else if ([object isKindOfClass:[NSArray class]]) {
                NSArray *subarray = [object arrayByRemovingNSNullRecursively:YES];
                [dictionary setValue:subarray forKey:key];
            }
        }
    }
    
    return [dictionary copy];
}
@end
