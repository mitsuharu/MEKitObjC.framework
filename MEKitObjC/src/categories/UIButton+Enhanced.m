//
//  UIButton+Enhanced.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/12/05.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import "UIButton+Enhanced.h"
#import "Categories.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@implementation UIButton (Enhanced)

+(UIButton*)customButton:(CGSize)size
                   title:(NSString*)title
               fontColor:(UIColor*)fontColor
               viewColor:(UIColor*)viewColor
             borderColor:(UIColor*)borderColor
                  corner:(NSInteger)corner
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, size.width, size.height)];
    [btn setExclusiveTouch:YES];
    
    [btn setBackgroundImage:[UIImage imageWithUIColor:viewColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithUIColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
    
    
    if (corner > 0) {
        btn.layer.cornerRadius = corner;
        btn.clipsToBounds = true;
    }
    
    if (borderColor) {
        [btn.layer setBorderColor:[borderColor CGColor]];
        [btn.layer setBorderWidth:1.0f];
    }
    
    
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:fontColor forState:UIControlStateNormal];
//    [btn setTintColor:fontColor];
    
    return btn;
}

+(void)customize:(UIButton**)button
            size:(CGSize)size
           title:(NSString*)title
       fontColor:(UIColor*)fontColor
       viewColor:(UIColor*)viewColor
highlightedColor:(UIColor*)highlightedColor
     borderColor:(UIColor*)borderColor
          corner:(NSInteger)corner
{
    UIButton *btn = *button;
    
    [btn setFrame:CGRectMake(0, 0, size.width, size.height)];
    [btn setExclusiveTouch:YES];
    
    [btn setBackgroundImage:[UIImage imageWithUIColor:viewColor] forState:UIControlStateNormal];
    
    if (highlightedColor) {
        [btn setBackgroundImage:[UIImage imageWithUIColor:highlightedColor] forState:UIControlStateHighlighted];
    }else{
        [btn setBackgroundImage:[UIImage imageWithUIColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
        
    }
    
    
    if (corner > 0) {
        btn.layer.cornerRadius = corner;
        btn.clipsToBounds = true;
    }
    
    if (borderColor) {
        [btn.layer setBorderColor:[borderColor CGColor]];
        [btn.layer setBorderWidth:1.0f];
    }
    
    
    [btn setTitle:title forState:UIControlStateNormal];
    [btn.titleLabel setTextColor:fontColor];
}

@end
