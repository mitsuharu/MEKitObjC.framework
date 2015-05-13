//
//  UIViewController+Enhanced.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/11/08.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import "UIViewController+Enhanced.h"
#import <objc/runtime.h>
#import "NSObject+Enhanced.h"

#define KEY_FirstResponserRect  @"KEY_FirstResponserRect"
#define KEY_keyboardRect        @"KEY_keyboardRect"
#define KEY_keyboardDuration    @"KEY_keyboardDuration"
#define KEY_keyboardCurve       @"KEY_keyboardCurve"


@implementation UIViewController (Enhanced)

+(UIViewController*)topLayerViewController
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *vc = window.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    return vc;
}

+(UIViewController*)instantiateWithStoryboard
{
    return [UIViewController instantiateWithStoryboard:NSStringFromClass([self class])
                                            identifier:NSStringFromClass([self class])];
}

+(UIViewController*)instantiateWithStoryboard:(NSString*)storyboard
{
    return [UIViewController instantiateWithStoryboard:storyboard
                                            identifier:storyboard];
}

+(UIViewController*)instantiateWithStoryboard:(NSString*)storyboard
                                   identifier:(NSString*)identifier
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:storyboard
                                                 bundle:[NSBundle mainBundle]];
    UIViewController *vc = nil;
    if (sb) {
        @try {
            vc = [sb instantiateViewControllerWithIdentifier:identifier];
        }
        @catch (NSException *exception) {
            NSLog(@"%s, exception %@", __func__, exception);
        }
        @finally {
        }
    }
    
    return vc;;
}


-(BOOL)isVisible
{
    return (self.isViewLoaded && self.view.window);
}

@end



@implementation UIViewController (Keyboard)

-(void)addKeyboardNotification
{
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    
    if (self && [self respondsToSelector:@selector(keyboardWillShow:)]) {
        [notification addObserver:self
                         selector:@selector(keyboardWillShow:)
                             name:UIKeyboardWillShowNotification
                           object:nil];
    }
    if (self && [self respondsToSelector:@selector(keyboardDidShow:)]) {
        [notification addObserver:self
                         selector:@selector(keyboardDidShow:)
                             name:UIKeyboardDidShowNotification
                           object:nil];
    }
    
    if (self && [self respondsToSelector:@selector(keyboardWillHide:)]) {
        [notification addObserver:self
                         selector:@selector(keyboardWillHide:)
                             name:UIKeyboardWillHideNotification
                           object:nil];
    }
    
    if (self && [self respondsToSelector:@selector(keyboardDidHide:)]) {
        [notification addObserver:self
                         selector:@selector(keyboardDidHide:)
                             name:UIKeyboardDidHideNotification
                           object:nil];
    }
    
}

-(void)removeKeyboardNotification
{
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    
    if (self && [self respondsToSelector:@selector(keyboardWillShow:)]) {
        [notification removeObserver:self
                                name:UIKeyboardWillShowNotification
                              object:nil];
    }
    
    if (self && [self respondsToSelector:@selector(keyboardDidShow:)]) {
        [notification removeObserver:self
                                name:UIKeyboardDidShowNotification
                              object:nil];
    }
    
    if (self && [self respondsToSelector:@selector(keyboardWillHide:)]) {
        [notification removeObserver:self
                                name:UIKeyboardWillHideNotification
                              object:nil];
    }
    
    if (self && [self respondsToSelector:@selector(keyboardDidHide:)]) {
        [notification removeObserver:self
                                name:UIKeyboardDidHideNotification
                              object:nil];
    }
    
}

-(CGRect)keyboardRect:(NSNotification*)notification
{
    CGRect rect = CGRectZero;
    if (notification) {
        if (notification.userInfo && [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]) {
            rect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        }
    }
    return rect;
}

-(NSTimeInterval)keyboardDuration:(NSNotification*)notification
{
    NSTimeInterval duration = 0.0;
    if (notification) {
        if (notification.userInfo && [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]) {
            duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        }
    }
    return duration;
}

-(UIViewAnimationCurve)keyboardCurve:(NSNotification*)notification
{
    UIViewAnimationCurve curve = UIViewAnimationCurveLinear;
    if (notification) {
        if (notification.userInfo && [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey]) {
            curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        }
    }
    return curve;
}


//-(void)fitShownKeyboard:(UIScrollView*)scrollView
//{
//    // DLog(@"");
//
//    CGRect kRect = [self keyboardRect];
//    NSTimeInterval kDuration = [self keyboardDuration];
//    UIViewAnimationCurve kCurve = [self keyboardCurve];
//
//    CGRect fRect = [self firstResponserRect];
//    CGFloat y = fRect.origin.y + fRect.size.height;
//    CGFloat diff = y - kRect.origin.y;
//
//    if (diff > 0) {
//        [UIView animateWithDuration:kDuration
//                              delay:0.0
//                            options:kCurve
//                         animations:^{
//                             CGSize size = scrollView.contentSize;
//                             size.height += diff;
//                             scrollView.contentSize = size;
//
//                             CGPoint p = scrollView.contentOffset;
//                             p.y += diff;
//                             scrollView.contentOffset = p;
//                         } completion:^(BOOL finished) {
//
//                             CGRect rect = fRect;
//                             rect.origin.y -= diff;
//                             [self setFirstResponserRect:rect];
//                         }];
//    }
//}

//-(void)fitHiddenKeyboard:(UIScrollView*)scrollView
//{
//    // DLog(@"");
//
//    NSTimeInterval kDuration = [self keyboardDuration];
//    UIViewAnimationCurve kCurve = [self keyboardCurve];
//
//    [UIView animateWithDuration:kDuration
//                          delay:0.0
//                        options:kCurve
//                     animations:^{
//                         scrollView.contentSize = [scrollView rawContentSize];
//                         //scrollView.contentOffset = [scrollView rawContentOffset];
//                     } completion:^(BOOL finished) {
//
//                     }];
//}


@end


@implementation UIViewController (NavigationControllerSwipeTransition)

-(void)disableNavigationControllerSwipeTransition
{
    if (self.navigationController
        && [self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = false;
    }
}

-(void)addMonitoringNavigationControllerSwipeTransition
{
    if (self.navigationController
        && [self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        UIGestureRecognizer *gr = self.navigationController.interactivePopGestureRecognizer;
        [gr addTarget:self
               action:@selector(handleInteractivePopGestureRecognizer:)];
    }
}

-(void)removeMonitoringNavigationControllerSwipeTransition
{
    if (self.navigationController
        && [self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        UIGestureRecognizer *gr = self.navigationController.interactivePopGestureRecognizer;
        [gr removeTarget:self
                  action:@selector(handleInteractivePopGestureRecognizer:)];
    }
}

-(void)handleInteractivePopGestureRecognizer:(UIGestureRecognizer*)gr
{
    UIGestureRecognizerState state = gr.state;
    if (state == UIGestureRecognizerStateBegan){
    }else if ( state == UIGestureRecognizerStateChanged){
    }else if ( state == UIGestureRecognizerStateEnded){
    }
    /*
     キャンセルイベントは取れない．UINavigationControllerDelegateの
     -(void)navigationController:(UINavigationController *)navigationController
     didShowViewController:(UIViewController *)viewController
     animated:(BOOL)animated;
     で表示されるのを取得するのが妥当か
     */
}

@end