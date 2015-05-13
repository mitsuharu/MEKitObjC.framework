//
//  NSMutableArray+Enhanced.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/05/13.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import "NSMutableArray+Enhanced.h"

@implementation NSMutableArray (Enhanced)

-(NSMutableArray*)split:(NSInteger)length
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:1];
    
    if (self.count > 0 && length > self.count) {
        [array addObject:self];
        return array;
    }
    
    NSInteger location = 0;
    for (int i = 0; i < ceilf(((float)self.count/(float)length)); i++) {
        NSRange range = NSMakeRange(location, length);
        if (range.location + range.length > self.count) {
            range.length = self.count - range.location;
        }
        [array addObject:(NSMutableArray*)[self subarrayWithRange:range]];
        location += range.length;
    }
    
    return array;
}

@end
