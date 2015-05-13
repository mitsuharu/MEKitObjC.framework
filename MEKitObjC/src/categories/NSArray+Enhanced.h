//
//  NSArray+Enhanced.h
//  MEKitObjC
//
//  Created by Masayoshi Ukida on 2014/05/22.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Enhanced)
- (NSArray*)arrayByRemovingNSNull;
- (NSArray*)arrayByRemovingNSNullRecursively:(BOOL)recursive;
@end
