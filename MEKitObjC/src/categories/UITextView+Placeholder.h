//
//  UITextView+Placeholder.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2014/11/17.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (Placeholder)

-(NSString*)placeholder;
-(void)setPlaceholder:(NSString*)placeholder;

-(UIColor*)placeholderColor;
-(void)setPlaceholderColor:(UIColor*)Color;

@end
