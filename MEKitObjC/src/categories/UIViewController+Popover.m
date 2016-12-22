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
#define KEY_VIEWCONTROLLER_POPOVER_BLOCK @"KEY_VIEWCONTROLLER_POPOVER_BLOCK"

#define ALPHA_BLANLVIEW 0.5

NSString *const kPopoeverSupportViewKey = @"kPopoeverSupportViewKey";
CGFloat const kPopoeverSupportViewAlhpa = 0.5;
CGFloat const kPopoeverSupportViewDuration = 0.25;

static BOOL isPopping = NO;

#pragma mark - UIViewController (Popover)

@implementation UIViewController (Popover)


// 追加分
- (void)setPopoverDidTapOutside:(MEOPopoverDidTapOutside)block
{
    MEOPopoverDidTapOutside temp = nil;
    if (block) {
        temp = [block copy];
    }
    objc_setAssociatedObject(self,
                             KEY_VIEWCONTROLLER_POPOVER_BLOCK,
                             temp,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}


- (void)handleGestureRecognizer:(UITapGestureRecognizer*)gr
{
    if (gr.state == UIGestureRecognizerStateEnded) {
        MEOPopoverDidTapOutside block = objc_getAssociatedObject(self,
                                                                 KEY_VIEWCONTROLLER_POPOVER_BLOCK);
        if (block) {
            block();
        }
    }
}



#pragma mark UIViewControllerのポップオーバー表示

-(void)presentPopoverViewController:(UIViewController*)viewController
                           animated:(BOOL)animated
                         completion:(void (^)(BOOL finished))completion
{    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
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
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        
    UIView *blankView = [[UIView alloc] initWithFrame:window.frame];
    [blankView setAlpha:ALPHA_BLANLVIEW];
    [blankView setBackgroundColor:[UIColor blackColor]];
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(handleGestureRecognizer:)];
    [blankView addGestureRecognizer:gr];
    
    
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
        
        for (UIGestureRecognizer *gr in blankView.gestureRecognizers.reverseObjectEnumerator) {
            [blankView removeGestureRecognizer:gr];
        }
        
        [blankView removeFromSuperview];
        objc_removeAssociatedObjects(blankView);
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        if (completion) {
            completion(YES);
        }
    }
}

#pragma mark UIViewのポップオーバー表示

-(void)addPopoverView:(UIView*)view
             animated:(BOOL)animated
           completion:(void (^)(BOOL finished))completion
{
    [self addPopoverView:view
                animated:animated
                duration:kPopoeverSupportViewDuration
              completion:completion];
}


-(void)addPopoverView:(UIView*)view
             animated:(BOOL)animated
             duration:(NSTimeInterval)duration
           completion:(void (^)(BOOL finished))completion
{
    if (view == nil || view.superview) {
        if (completion) {
            completion(false);
        }
        return;
    }
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    
    UIView *blankView = [[UIView alloc] initWithFrame:window.frame];
    blankView.alpha = kPopoeverSupportViewAlhpa;
    blankView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(handleGestureRecognizer:)];
    [blankView addGestureRecognizer:gr];
    [window addSubview:blankView];
    
    objc_setAssociatedObject(view,
                             (__bridge const void *)(kPopoeverSupportViewKey),
                             blankView,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // キーボードの通知を開始する
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:view
                     selector:@selector(keyboardWillShow:)
                         name:UIKeyboardDidShowNotification
                       object:nil];
    [notification addObserver:view
                     selector:@selector(keyboardWillHide:)
                         name:UIKeyboardWillHideNotification
                       object:nil];
    
    
    [window addSubview:view];
    view.alpha = 1.0;
    view.center = CGPointMake(window.frame.size.width/2,
                              window.frame.size.height/2);
    
//    view.layer.cornerRadius = 5;
//    view.clipsToBounds = true;
    
    //    // 影付け
    //    view.layer.shadowOpacity = 0.2;
    //    view.layer.shadowOffset = CGSizeMake(10.0, 10.0);
    
    if (animated) {
        
        NSTimeInterval animateDuration = duration;
        
        blankView.alpha = 0.0;
        view.alpha = 0.0;
        for (UIView *v in view.subviews) {
            v.alpha = 0.0;
        }
        
        CGFloat scale = 0.5;
        view.transform = CGAffineTransformMakeScale(scale, scale);
        
        [UIView animateWithDuration:animateDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             blankView.alpha = kPopoeverSupportViewAlhpa;
                             view.alpha = 1.0;
                             view.transform = CGAffineTransformIdentity;
                             for (UIView *v in view.subviews) {
                                 v.alpha = 1.0;
                             }
                         } completion:^(BOOL finished) {
                             if (completion) {
                                 completion(finished);
                             }
                         }];
    }else{
        view.alpha = 1.0;
        if (completion) {
            completion(true);
        }
    }
    
}


#pragma mark キーボード通知

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

#pragma mark - UIView (Popover)


@implementation UIView (Popover)


-(void)removeFromPopoverAnimated:(BOOL)animated
                      completion:(void (^)(BOOL finished))completion
{
    if (self == nil || self.superview == nil) {
        if (completion) {
            completion(false);
        }
        return;
    }
    
    
    UIView *blankView = objc_getAssociatedObject(self, (__bridge const void *)(kPopoeverSupportViewKey));
    
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [notification removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
    void (^completionBlock)(BOOL finish) = ^(BOOL finished) {
        if (blankView) {
            [blankView removeFromSuperview];
            objc_removeAssociatedObjects(blankView);
        }
        [self removeFromSuperview];
        if (completion) {
            completion(finished);
        }
    };
    
    if (animated) {
        self.alpha = 1.0;
        if (blankView) {
            blankView.alpha = kPopoeverSupportViewAlhpa;
        }
        
        [UIView animateWithDuration:kPopoeverSupportViewDuration
                         animations:^{
                             self.alpha = 0.0;
                             if (blankView) {
                                 blankView.alpha = 0.0;
                             }
                         } completion:^(BOOL finished) {
                             completionBlock(finished);
                         }];
    }else{
        completionBlock(true);
    }
}

-(void)keyboardWillShow:(NSNotification*)notification
{
    // DLog(@"");
    
    UIView *superview = self.superview;
    UIView *blankView = objc_getAssociatedObject(self, (__bridge const void *)(kPopoeverSupportViewKey));
    if (blankView) {
        [superview bringSubviewToFront:blankView];
    }
    [superview bringSubviewToFront:self];
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    // DLog(@"");
}

@end

