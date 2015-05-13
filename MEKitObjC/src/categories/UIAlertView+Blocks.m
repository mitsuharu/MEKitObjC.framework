//
//  UIAlertView+Blocks.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/01/22.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import "UIAlertView+Blocks.h"
#import <objc/runtime.h>

#define KEY_ALERTVIEW_CALLBACK @"KEY_ALERTVIEW_CALLBACK"

@implementation UIAlertView (Blocks)


-(id)initWithTitle:(NSString *)title
           message:(NSString *)message
        completion:(AlertViewCompletion)completion
 cancelButtonTitle:(NSString *)cancelButtonTitle
 otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [self initWithTitle:title
                       message:message
                      delegate:nil
             cancelButtonTitle:cancelButtonTitle
             otherButtonTitles:nil];
    
    if(self) {
        va_list args;
        va_start(args, otherButtonTitles);
        for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*)) {
            [self addButtonWithTitle:arg];
        }
        va_end(args);
        
        objc_setAssociatedObject(self,
                                 KEY_ALERTVIEW_CALLBACK,
                                 [completion copy],
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        self.delegate = self;
    }
    return self;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AlertViewCompletion completion = objc_getAssociatedObject(self,
                                                              KEY_ALERTVIEW_CALLBACK);
    if (completion) {
        completion(self, buttonIndex);
    }
}


@end
