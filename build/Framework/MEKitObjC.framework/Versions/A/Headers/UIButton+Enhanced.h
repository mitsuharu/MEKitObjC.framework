//
//  UIButton+Enhanced.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/12/05.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Enhanced)


+(UIButton*)customButton:(CGSize)size
                   title:(NSString*)title
               fontColor:(UIColor*)fontColor
               viewColor:(UIColor*)viewColor
             borderColor:(UIColor*)borderColor
                  corner:(NSInteger)corner;

+(void)customize:(UIButton**)button
            size:(CGSize)size
           title:(NSString*)title
       fontColor:(UIColor*)fontColor
       viewColor:(UIColor*)viewColor
highlightedColor:(UIColor*)highlightedColor
     borderColor:(UIColor*)borderColor
          corner:(NSInteger)corner;


@end
