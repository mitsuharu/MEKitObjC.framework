//
//  UIViewController+Popover.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/02/01.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import "UIViewController+Popover.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "NSObject+Enhanced.h"

#define KEY_VIEWCONTROLLER_POPOVER_BLANKVIEW @"KEY_VIEWCONTROLLER_POPOVER_BLANKVIEW"

#define ALPHA_BLANLVIEW 0.5
//#define POPOVER_ANIMATION_DURATION 0.25
//#define POPOVER_ANIMATION_DURATION_CLOSE 0.3

static BOOL isPopping = NO;

@implementation UIViewController (Popover)

-(void)presentPopoverViewController:(UIViewController*)viewController
                           animated:(BOOL)animated
                         completion:(void (^)(BOOL finished))completion
{    
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    CGFloat scaleX = 0.8;
    CGFloat scaleY = 0.8;    
    CGSize size = CGSizeMake(floorf(window.frame.size.width*scaleX),
                             floorf(window.frame.size.height*scaleY));
    
    [self presentPopoverViewController:viewController
                              viewSize:size
                              animated:animated
                              duration:POPOVER_ANIMATION_DURATION
                            completion:completion];
}


-(void)presentPopoverViewController:(UIViewController*)viewController
                           viewSize:(CGSize)viewSize
                           animated:(BOOL)animated
                           duration:(NSTimeInterval)duration
                         completion:(void (^)(BOOL finished))completion
{
    if (isPopping) {
        return;
    }
    isPopping = YES;
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
        
    UIView *blankView = [[UIView alloc] initWithFrame:window.frame];
    [blankView setAlpha:ALPHA_BLANLVIEW];
    [blankView setBackgroundColor:[UIColor blackColor]];
    [window addSubview:blankView];
    
    objc_setAssociatedObject(viewController,
                             KEY_VIEWCONTROLLER_POPOVER_BLANKVIEW,
                             blankView,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    // キーボードの通知を開始する
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:viewController
                     selector:@selector(keyboardWillShow:)
						 name:UIKeyboardDidShowNotification
                       object:nil];
    [notification addObserver:viewController
                     selector:@selector(keyboardWillHide:)
                         name:UIKeyboardWillHideNotification
                       object:nil];
    
    
    viewController.view.alpha = 1.0;
    viewController.view.frame = CGRectMake(0.0,
                                           0.0,
                                           viewSize.width,
                                           viewSize.height);
    [window addSubview:viewController.view];
    viewController.view.center = CGPointMake(window.frame.size.width/2,
                                             window.frame.size.height/2);
    
    viewController.view.layer.cornerRadius = 5;
    viewController.view.clipsToBounds = true;
    
//    // 影付け
//    viewController.view.layer.shadowOpacity = 0.2;
//    viewController.view.layer.shadowOffset = CGSizeMake(10.0, 10.0);
    
    if (animated) {
        
        NSTimeInterval animateDuration = duration;
        
        blankView.alpha = 0.0;
        viewController.view.alpha = 0.0;
        for (UIView *v in viewController.view.subviews) {
            v.alpha = 0.0;
        }
        
        CGFloat scale = 0.5;
        viewController.view.transform = CGAffineTransformMakeScale(scale, scale);
        
        [UIView animateWithDuration:animateDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             blankView.alpha = ALPHA_BLANLVIEW;
                             viewController.view.alpha = 1.0;
                             viewController.view.transform = CGAffineTransformIdentity;
                             for (UIView *v in viewController.view.subviews) {
                                 v.alpha = 1.0;
                             }
                         } completion:^(BOOL finished) {
                             isPopping = NO;
//                             [self performBlock:^{
//                                 isPopping = NO;
//                             } afterDelay:1.0];
                             
                             @try {
                                 [self addChildViewController:viewController];
                             }
                             @catch (NSException *exception) {
                                 NSLog(@"%s, exception:%@", __func__, exception.debugDescription);
                             }
                             @finally {  
                             }
                             
                             //[self addChildViewController:viewController];
                             if (completion) {
                                 completion(finished);
                             }
                         }];
    }else{
        viewController.view.alpha = 1.0;
        @try {
            [self addChildViewController:viewController];
        }
        @catch (NSException *exception) {
            NSLog(@"%s, exception:%@", __func__, exception.debugDescription);
        }
        @finally {            
        }
        [self performBlock:^{
            isPopping = NO;
        } afterDelay:1.0];
        if (completion) {
            completion(YES);
        }
    }
    
}


-(void)dismissPopoverViewControllerAnimated:(BOOL)animated
                                 completion:(void (^)(BOOL finished))completion
{
    UIView *blankView = objc_getAssociatedObject(self, KEY_VIEWCONTROLLER_POPOVER_BLANKVIEW);
    
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [notification removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
    if (animated) {
        self.view.alpha = 1.0;
        blankView.alpha = ALPHA_BLANLVIEW;
        [UIView animateWithDuration:POPOVER_ANIMATION_DURATION_CLOSE
                         animations:^{
                             self.view.alpha = 0.0;
                             blankView.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [blankView removeFromSuperview];
                             objc_removeAssociatedObjects(blankView);
                             [self.view removeFromSuperview];
                             [self removeFromParentViewController];
                             if (completion) {
                                 completion(finished);
                             }
                         }];
    }else{
        [blankView removeFromSuperview];
        objc_removeAssociatedObjects(blankView);
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        if (completion) {
            completion(YES);
        }
    }
}


#pragma mark - キーボード通知

-(void)keyboardWillShow:(NSNotification*)notification
{
    // DLog(@"");
    
    UIView *superview = self.view.superview;
    UIView *blankView = objc_getAssociatedObject(self, KEY_VIEWCONTROLLER_POPOVER_BLANKVIEW);
    if (blankView) {
        [superview bringSubviewToFront:blankView];
    }    
    [superview bringSubviewToFront:self.view];
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    // DLog(@"");
}

@end


