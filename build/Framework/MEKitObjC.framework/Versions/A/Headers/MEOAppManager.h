//
//  MEOAppManager.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2014/11/19.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface MEOAppManager : NSObject

+(NSString*)appName;
+(NSString*)appScheme;

+(BOOL)openApp:(NSString*)urlScheme;
+(BOOL)openMapsApp:(NSString*)target;

@end
