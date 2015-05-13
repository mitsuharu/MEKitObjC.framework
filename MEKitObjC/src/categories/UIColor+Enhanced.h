//
//  UIColor+Enhanced.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/06/27.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RGB(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

#define RGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]

@interface UIColor (Enhanced)

+(UIColor*)colorWithHexCode:(NSString*)colorCode;
-(id)initWithHexCode:(NSString*)colorCode;

-(NSString*)hexCode;
- (UIColor *)darkColor;
- (UIColor *)makeBlendColorWithColor:(UIColor*)color weight:(float)weight;

@end
