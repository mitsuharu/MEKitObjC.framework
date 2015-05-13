//
//  UITextView+Placeholder.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2014/11/17.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import "UITextView+Placeholder.h"
#import <objc/runtime.h>

static void *const kPlaceholder;
static void *const kPlaceholderColor;
static void *const kPlaceholderLabel;

@interface UITextView (Placeholder_Private)

-(UILabel*)placeholderLabel;
-(void)addPlaceholderLabel:(NSString*)string;
-(void)hidePlaceholderLabel:(BOOL)hide;
-(void)removePlaceholderLabel;
-(void)textChanged:(NSNotification*)notification;

@end

@implementation UITextView (Placeholder_Private)

-(UILabel*)placeholderLabel
{
    UILabel *label = objc_getAssociatedObject(self, &kPlaceholderLabel);
    if (label == nil) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(8,8,self.bounds.size.width - 16, self.frame.size.width/2)];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
        label.font = self.font;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [self placeholderColor];
        
        objc_setAssociatedObject(self,
                                 &kPlaceholderLabel,
                                 label,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return label;
}

-(void)addPlaceholderLabel:(NSString*)string
{
    UILabel *label = [self placeholderLabel];
    if (label) {
        label.text = string;
        [label sizeToFit];
        
        if (label.superview == nil) {
            [self addSubview:label];
        }
        
        if (self.text == nil || self.text.length == 0) {
            [self hidePlaceholderLabel:NO];
        }else{
            [self hidePlaceholderLabel:YES];
        }
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(textChanged:)
                   name:UITextViewTextDidChangeNotification
                 object:nil];
    }
}

-(void)hidePlaceholderLabel:(BOOL)hide
{
    UILabel *label = objc_getAssociatedObject(self, &kPlaceholderLabel);
    if (hide) {
        label.alpha = 0.0;
    }else{
        label.alpha = 1.0;
    }
}


-(void)removePlaceholderLabel
{
    UILabel *label = objc_getAssociatedObject(self, &kPlaceholderLabel);
    if (label) {
        [label removeFromSuperview];
        objc_setAssociatedObject(self,
                                 &kPlaceholderLabel,
                                 nil,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    }
}

-(void)textChanged:(NSNotification*)notification
{
    NSString *placeholder = [self placeholder];
    if (placeholder == nil || placeholder.length == 0) {
        return;
    }
    
    if (self.text == nil || self.text.length == 0) {
        [self hidePlaceholderLabel:NO];
    }else{
        [self hidePlaceholderLabel:YES];
    }
}

@end

@implementation UITextView (Placeholder)

-(UIColor*)placeholderColor
{
    UIColor *color = objc_getAssociatedObject(self, &kPlaceholderColor);
    if (color == nil) {
        color = [UIColor lightGrayColor];
    }
    return color;
}

-(void)setPlaceholderColor:(UIColor*)color
{
    objc_setAssociatedObject(self,
                             &kPlaceholderColor,
                             color,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


-(NSString*)placeholder
{
    NSString *str = objc_getAssociatedObject(self, &kPlaceholder);
    return str;
}

-(void)setPlaceholder:(NSString*)placeholder
{
    objc_setAssociatedObject(self,
                             &kPlaceholder,
                             placeholder,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (placeholder && placeholder.length > 0) {
        [self addPlaceholderLabel:placeholder];
    }else{
        [self removePlaceholderLabel];
    }
}

@end
