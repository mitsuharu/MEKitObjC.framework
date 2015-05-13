//
//  NSError+Enhanced.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/04/30.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/**
 It is an error code of MEOAuthorization
 */
typedef NS_ENUM(NSInteger, MEOErrorCode) {
    MEOErrorCodeUnknown = 10000,
    MEOErrorCodeNetworkFailed,
    MEOErrorCodeServerFailed,
};

@interface NSError (Enhanced)

+(NSError*)errorWithErrorCode:(NSInteger)code
         localizedDescription:(NSString*)localizedDescription;

@end
