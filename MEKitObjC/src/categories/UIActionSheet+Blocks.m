//
//  UIActionSheet+Blocks.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/01/22.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import "UIActionSheet+Blocks.h"
#import <objc/runtime.h>

#define KEY_ACTIONSHEET_CALLBACK @"KEY_ACTIONSHEET_CALLBACK"

@implementation UIActionSheet (Blocks)

-(id)initWithTitle:(NSString *)title
        completion:(ActionSheetCompletion)completion
 cancelButtonTitle:(NSString *)cancelButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
 otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [self initWithTitle:title
                      delegate:nil
             cancelButtonTitle:nil
        destructiveButtonTitle:nil
             otherButtonTitles:nil];
    
    if(self) {
        
        if (destructiveButtonTitle) {
            [self addButtonWithTitle:destructiveButtonTitle];
            self.destructiveButtonIndex = 0;
        }
        
        va_list args;
        va_start(args, otherButtonTitles);
        for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*)) {
            [self addButtonWithTitle:arg];
        }
        va_end(args);
        
        if (cancelButtonTitle) {
            [self addButtonWithTitle:cancelButtonTitle];
            self.cancelButtonIndex = self.numberOfButtons - 1;
        }

        objc_setAssociatedObject(self,
                                 KEY_ACTIONSHEET_CALLBACK,
                                 [completion copy],
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        self.delegate = self;
    }
    return self;
}


-(void)setCompletion:(ActionSheetCompletion)completion
{
    if (completion) {
        self.delegate = self;
        objc_setAssociatedObject(self,
                                 KEY_ACTIONSHEET_CALLBACK,
                                 [completion copy],
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ActionSheetCompletion completion = objc_getAssociatedObject(self, KEY_ACTIONSHEET_CALLBACK);
    if (completion) {
        completion(self, buttonIndex);
    }
}


@end
