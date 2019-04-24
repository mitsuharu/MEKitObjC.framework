//
//  UITabBarController+Extension.m
//  BramoDemo
//
//  Created by Mitsuharu Emoto on 2014/12/25.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import "UITabBarController+Extension.h"

#define AnimatedInterval 0.20f

static BOOL currentHidden = NO;
static BOOL hasRotationNotification = NO;
static BOOL showTabBarTemporally = NO;
static BOOL hideTabBarTemporally = NO;

@interface UITabBarController (private)

-(CGSize)screenSize;
-(CGRect)screenRect;

-(void)startRotationNotification;
-(void)stopRotationNotification;
-(void)didRotate:(NSNotification *)notification;

-(void)tabBarHidden:(BOOL)hidden animated:(BOOL)animated;

@end

@implementation UITabBarController (private)

-(CGRect)screenRect
{
    CGRect rect = [UIScreen mainScreen].bounds;
    UIApplication *app = [UIApplication sharedApplication];
    UIInterfaceOrientation orient = [app statusBarOrientation];
    if ((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
        && UIInterfaceOrientationIsLandscape(orient)) {
        return CGRectMake(0, 0, rect.size.height, rect.size.width);
    }
    return rect;
}

-(CGSize)screenSize
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIApplication *app = [UIApplication sharedApplication];
    UIInterfaceOrientation orient = [app statusBarOrientation];
    if ((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
        && UIInterfaceOrientationIsLandscape(orient)) {
        return CGSizeMake(screenSize.height, screenSize.width);
    }
    return screenSize;
}

-(void)startRotationNotification
{
//    NSLog(@"%s", __func__);
    
    UIDevice *device = [UIDevice currentDevice];
    if ([device isGeneratingDeviceOrientationNotifications] == NO) {
        [device beginGeneratingDeviceOrientationNotifications];
    }
    
    if ([self respondsToSelector:@selector(viewWillTransitionToSize:withTransitionCoordinator:)]) {

        if (hasRotationNotification == NO) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didRotate:)
                                                         name:UIDeviceOrientationDidChangeNotification
                                                       object:nil];
            hasRotationNotification = YES;
        }
    }
}

-(void)stopRotationNotification
{
    UIDevice *device = [UIDevice currentDevice];
    if ([device isGeneratingDeviceOrientationNotifications]) {
        [device endGeneratingDeviceOrientationNotifications];
    }
    
    if ([self respondsToSelector:@selector(viewWillTransitionToSize:withTransitionCoordinator:)]) {
        
        if (hasRotationNotification) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIDeviceOrientationDidChangeNotification
                                                      object:nil];
            hasRotationNotification = NO;
        }
    }
}

-(void)didRotate:(NSNotification *)notification
{
    UIDeviceOrientation orient = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsPortrait(orient) || UIDeviceOrientationIsLandscape(orient)) {
        if (hideTabBarTemporally) {
            [self viewDidLayoutSubviews];
        }
    }
}

-(void)tabBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    [self startRotationNotification];
    
    CGSize screenSize = [self screenSize];
    
    NSTimeInterval interval = 0.0;
    if (animated) {
        interval = AnimatedInterval;
    }
    
    CGRect tabRectStarted = self.tabBar.frame;
    CGRect tabRectFinished = self.tabBar.frame;
    CGRect viewRectStarted = self.selectedViewController.view.frame;
    CGRect viewRectFinished = self.selectedViewController.view.frame;
    
    CGFloat alpha = 0.1;
    if (hidden) {
        alpha = 0.1;
    }else{
        alpha = 1.0;
    }
    
    if ([self.tabBar respondsToSelector:@selector(barTintColor)]){
        // over iOS7
        if (hidden) {
            tabRectStarted.origin.y = screenSize.height - self.tabBar.frame.size.height;
            tabRectFinished.origin.y = screenSize.height;
            
            viewRectStarted.size.height = screenSize.height;
            viewRectFinished.size.height = screenSize.height + self.tabBar.frame.size.height;
        }else{
            tabRectStarted.origin.y = screenSize.height;
            tabRectFinished.origin.y = screenSize.height - self.tabBar.frame.size.height;
            
            viewRectStarted.size.height = screenSize.height + self.tabBar.frame.size.height;
            viewRectFinished.size.height = screenSize.height;
        }
    }else{
        // under iOS6
        CGFloat offset = [UIApplication sharedApplication].statusBarFrame.size.height;
        if (hidden) {
            tabRectStarted.origin.y = screenSize.height - self.tabBar.frame.size.height;
            tabRectFinished.origin.y = screenSize.height;
            
            viewRectFinished.size.height = viewRectFinished.size.height + self.tabBar.frame.size.height - offset;
        }else{
            tabRectStarted.origin.y = screenSize.height;
            tabRectFinished.origin.y = screenSize.height - self.tabBar.frame.size.height;
            
            viewRectFinished.size.height = viewRectFinished.size.height - self.tabBar.frame.size.height + offset;
        }
    }
    
    if ([self.tabBar respondsToSelector:@selector(barTintColor)]){
        self.tabBar.frame = tabRectStarted;
        self.selectedViewController.view.frame = viewRectStarted;
    }else{
        for (UIView *subview in self.view.subviews){
            if (subview == self.tabBar){
                subview.frame = tabRectStarted;
            }else{
                subview.frame = viewRectStarted;
            }
        }
    }
    
    [UIView animateWithDuration:interval
                     animations:^{
                         
                         self.tabBar.alpha = alpha;
                         
                         if ([self.tabBar respondsToSelector:@selector(barTintColor)]){
                             self.tabBar.frame = tabRectFinished;
                             self.selectedViewController.view.frame = viewRectFinished;
                         }else{
                             for (UIView *subview in self.view.subviews){
                                 if (subview == self.tabBar){
                                     subview.frame = tabRectFinished;
                                 }else{
                                     subview.frame = viewRectFinished;
                                 }
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                         self.tabBar.hidden = hidden;
                         self.tabBar.alpha = alpha;
                     }];
}



@end

@implementation UITabBarController (Extension)

- (void)viewWillTransitionToSize:(CGSize)size
        withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (self.tabBar.hidden) {
            showTabBarTemporally = YES;
            [self tabBarHidden:NO animated:NO];
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (showTabBarTemporally) {
            showTabBarTemporally = NO;
            [self tabBarHidden:YES animated:NO];
        }
    }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

-(void)willTransitionToTraitCollection:(UITraitCollection *)newCollection
             withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if (self.tabBar.hidden) {
        showTabBarTemporally = YES;
    }
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ([self respondsToSelector:@selector(viewWillTransitionToSize:withTransitionCoordinator:)]) {
        
        if (showTabBarTemporally) {
            showTabBarTemporally = NO;
            hideTabBarTemporally = YES;
            [self tabBarHidden:NO animated:NO];
        }else if (hideTabBarTemporally){
            hideTabBarTemporally = NO;
            [self tabBarHidden:YES animated:NO];
        }else{
            [self tabBarHidden:currentHidden animated:NO];
        }

    }
    [self.view layoutIfNeeded];

}

-(void)hideTabBar:(BOOL)hidden animated:(BOOL)animated
{
    currentHidden = hidden;
    [self tabBarHidden:hidden animated:animated];
}

@end
