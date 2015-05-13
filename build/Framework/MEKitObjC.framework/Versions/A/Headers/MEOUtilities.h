//
//  MEOUtilities.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2014/10/30.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface MEOUtilities : NSObject

+(NSBundle*)resourceBundle;
+(UIImage*)imageOfResourceBundle:(NSString*)name;

+(NSString*)localizedString:(NSString*)key;
+(NSString*)localizedString:(NSString*)key comment:(NSString*)comment;

@end
