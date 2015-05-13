//
//  NSError+Enhanced.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/04/30.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import "NSError+Enhanced.h"

@implementation NSError (Enhanced)


+(NSError*)errorWithErrorCode:(NSInteger)code
         localizedDescription:(NSString*)localizedDescription
{
    NSString *str = @"It is unknown error.";
    if (localizedDescription && localizedDescription.length > 0) {
        str = localizedDescription;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:str
                                                     forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                         code:code
                                     userInfo:dict];
    return error;
}


@end

