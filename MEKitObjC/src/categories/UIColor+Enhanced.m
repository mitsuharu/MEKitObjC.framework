//
//  UIColor+Enhanced.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/06/27.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import "UIColor+Enhanced.h"

@interface UIColor (Private)

+(void)hexCode:(NSString*)hexCode r:(NSInteger*)r g:(NSInteger*)g b:(NSInteger*)b;

@end


@implementation UIColor (Private)

+(void)hexCode:(NSString*)hexCode r:(NSInteger*)r g:(NSInteger*)g b:(NSInteger*)b
{
    NSString *plainColorCode = hexCode;
    NSRange range1 = [hexCode rangeOfString:@"0x"];
    NSRange range2 = [hexCode rangeOfString:@"#"];
    if (range1.location != NSNotFound) {
        plainColorCode = [hexCode substringWithRange:NSMakeRange(2, hexCode.length-2)];
    }else if (range2.location != NSNotFound) {
        plainColorCode = [hexCode substringWithRange:NSMakeRange(1, hexCode.length-1)];
    }
    
    unsigned int rgb[3];
    for (int i = 0; i < 3; i++) {
        NSString *component = [plainColorCode substringWithRange:NSMakeRange(i * 2, 2)];
        NSScanner *scanner = [NSScanner scannerWithString:component];
        [scanner scanHexInt:&rgb[i]];
//        NSLog(@"%s, %d", __func__, rgb[i]);
    }
    
    *r = rgb[0];
    *g = rgb[1];
    *b = rgb[2];
}


@end

@implementation UIColor (Enhanced)

+(UIColor*)colorWithHexCode:(NSString*)colorCode
{
    NSInteger r, g, b;
    [UIColor hexCode:colorCode r:&r g:&g b:&b];

    UIColor *color = [UIColor colorWithRed:r/255.0
                                     green:g/255.0
                                      blue:b/255.0
                                     alpha:1.0];
    return color;
}

-(id)initWithHexCode:(NSString*)colorCode
{
    NSInteger r, g, b;
    [UIColor hexCode:colorCode r:&r g:&g b:&b];
    
    UIColor *color = [[UIColor alloc] initWithRed:r/255.0
                                            green:g/255.0
                                             blue:b/255.0
                                            alpha:1.0];
    
    return color;
}


-(NSString*)hexCode
{
    NSString *hexCode = nil;
    CGFloat r, g, b, a;
    if ([self getRed:&r green:&g blue:&b alpha:&a]) {
        NSInteger r2 = r * 255;
        NSInteger g2 = g * 255;
        NSInteger b2 = b * 255;
        hexCode = [NSString stringWithFormat:@"#%02lx%02lx%02lx", (long)r2, (long)g2, (long)b2];
    }
    return hexCode;
}

- (UIColor *)darkColor
{
    UIColor *color = [UIColor colorWithWhite:0.0 alpha:0.5];
    UIColor *blendedColor = [self makeBlendColorWithColor:color weight:50.0];
    return blendedColor;
}

// weight:　0～100
- (UIColor *)makeBlendColorWithColor:(UIColor*)color weight:(float)weight
{
    CGFloat r1,g1,b1,r2,g2,b2,alpha;
    
    //RGB値を求める
    [self getRed:&r1 green:&g1 blue:&b1 alpha:&alpha];
    [color getRed:&r2 green:&g2 blue:&b2 alpha:&alpha];
    
    //色成分を混合
    float red = (r2*weight + r1*(100.0 - weight))/100.0;
    float green = (g2*weight + g1*(100.0 - weight))/100.0;
    float blue = (b2*weight + b1*(100.0 - weight))/100.0;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

@end
