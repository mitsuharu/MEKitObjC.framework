//
//  UILabel+Enhanced.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/06/18.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Enhanced)

@end

@interface UILabel (Vertical)

-(BOOL)verticalWriting;
-(void)setVerticalWriting:(BOOL)verticalWriting;

-(UIEdgeInsets)verticalPadding;
-(void)setVerticalPadding:(UIEdgeInsets)padding;

@end
