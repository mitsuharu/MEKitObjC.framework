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
    NSString *className = NSStringFromClass([self class]);
    NSArray *array = [className componentsSeparatedByString:@"."];
    NSString *str = array.lastObject;

    return [UIViewController instantiateWithStoryboard:str
                                            identifier:str];
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


-(BOOL)meo_isVisible
{
    // see http://stackoverflow.com/questions/2777438/how-to-tell-if-uiviewcontrollers-view-is-visible
    
    if (self.navigationController) {
        return (self.navigationController.visibleViewController == self
                && self.presentedViewController == nil);
    }else if (self.tabBarController){
        return (self.tabBarController.selectedViewController == self
                && self.presentedViewController == nil);
    }else{
        return (self.isViewLoaded
                && self.view.window
                && self.presentedViewController == nil);
    }
}

@end


@implementation MEOKeyboard

- (instancetype)initWithNotification:(NSNotification*)notification
{
    if (self = [super init]){
        if (notification) {
            self.frame = CGRectZero;
            self.duration = 0.0;
            self.curve = UIViewAnimationCurveLinear;
            self.opt = UIViewAnimationOptionCurveLinear;
            
            if (notification.userInfo && [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]) {
                self.frame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
            }
            if (notification.userInfo && [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]) {
                self.duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
            }
            if (notification.userInfo && [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey]) {
                self.curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
                self.opt = (self.curve << 16);
            }
        }
    }
    return self;
}

@end

@implementation UIViewController (Keyboard)

-(void)addKeyboardNotification
{
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
 
    if (self && [self respondsToSelector:@selector(meoKeyboardWillShow:)]) {
        [notification addObserver:self
                         selector:@selector(meoKeyboardWillShow:)
                             name:UIKeyboardWillShowNotification
                           object:nil];
    }
    if (self && [self respondsToSelector:@selector(meoKeyboardDidShow:)]) {
        [notification addObserver:self
                         selector:@selector(meoKeyboardDidShow:)
                             name:UIKeyboardDidShowNotification
                           object:nil];
    }
    if (self && [self respondsToSelector:@selector(meoKeyboardWillHide:)]) {
        [notification addObserver:self
                         selector:@selector(meoKeyboardWillHide:)
                             name:UIKeyboardWillHideNotification
                           object:nil];
    }
    if (self && [self respondsToSelector:@selector(meoKeyboardDidHide:)]) {
        [notification addObserver:self
                         selector:@selector(meoKeyboardDidHide:)
                             name:UIKeyboardDidHideNotification
                           object:nil];
    }
}

-(void)removeKeyboardNotification
{
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    
    if (self && [self respondsToSelector:@selector(meoKeyboardWillShow:)]) {
        [notification removeObserver:self
                                name:UIKeyboardWillShowNotification
                              object:nil];
    }
    
    if (self && [self respondsToSelector:@selector(meoKeyboardDidShow:)]) {
        [notification removeObserver:self
                                name:UIKeyboardDidShowNotification
                              object:nil];
    }
    
    if (self && [self respondsToSelector:@selector(meoKeyboardWillHide:)]) {
        [notification removeObserver:self
                                name:UIKeyboardWillHideNotification
                              object:nil];
    }
    
    if (self && [self respondsToSelector:@selector(meoKeyboardDidHide:)]) {
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