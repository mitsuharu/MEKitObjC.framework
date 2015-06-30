//
//  UIViewController+NavigationDrawer.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/01/13.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import "UIViewController+NavigationDrawer.h"
#import <objc/runtime.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

#define KeyWidthScale @"KeyWidthScale"
#define KeyImageView @"KeyImageView"
#define KeyClosureView @"KeyClosureView"
#define KeyClosureWindow @"KeyClosureWindow"
#define KeyTapCompletion @"KeyTapCompletion"
#define KeyIsDrawing @"KeyIsDrawing"
#define KeyFromLeft @"KeyFromLeft"

typedef void (^TapCompletion)(void);

@interface UIViewController (NavigationDrawer_Private)

-(CGRect)screenRect;
-(CGFloat)widthScale;
-(NSTimeInterval)timeInterval:(BOOL)animated;

-(UIWindow*)closureWindow;
-(void)deleteClosureWindow;

-(UIView*)closureView:(TapCompletion)completion;
-(void)deleteClosureView;

-(UIImage*)screenshot;
-(UIImageView*)imageView;
-(void)deleteImageView;

-(void)handleTapGestureRecognizer:(UITapGestureRecognizer *)gr;

-(BOOL)isDrawing;
-(void)setIsDrawing:(BOOL)isDrawing;

-(BOOL)fromLeft;
-(void)setFromLeft:(BOOL)fromLeft;

@end

@implementation UIViewController (NavigationDrawer_Private)

-(UIImage*)screenshot
{
    UIImage *image = nil;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [window.layer renderInContext:context];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(CGRect)screenRect
{
    return [[UIScreen mainScreen] bounds];
}

-(CGFloat)widthScale
{
    CGFloat scale = 4.0/5.0;
    NSNumber *number = objc_getAssociatedObject(self, KeyWidthScale);
    if (number) {
        scale = [number floatValue];
    }
    return scale;
}

-(NSTimeInterval)timeInterval:(BOOL)animated
{
    NSTimeInterval interval = 0.0;
    if (animated) {
        interval = 0.25;
    }
    return interval;
}

-(BOOL)isDrawing
{
    BOOL result = NO;
    NSNumber *number = objc_getAssociatedObject(self, KeyIsDrawing);
    if (number) {
        result = [number boolValue];
    }
    return result;
}

-(void)setIsDrawing:(BOOL)isDrawing
{
    objc_setAssociatedObject(self,
                             KeyIsDrawing,
                             [NSNumber numberWithBool:isDrawing],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)fromLeft
{
    BOOL result = true;
    NSNumber *number = objc_getAssociatedObject(self, KeyFromLeft);
    if (number) {
        result = [number boolValue];
    }
    return result;
}

-(void)setFromLeft:(BOOL)fromLeft
{
    objc_setAssociatedObject(self,
                             KeyFromLeft,
                             [NSNumber numberWithBool:fromLeft],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


-(void)handleTapGestureRecognizer:(UITapGestureRecognizer *)gr
{
    TapCompletion comp = objc_getAssociatedObject(self, KeyTapCompletion);
    if (comp) {
        comp();
    }
}

-(UIImageView*)imageView
{
    UIImageView *view = objc_getAssociatedObject(self, KeyImageView);
    if (view == nil) {
        UIImage *image = [self screenshot];
        view = [[UIImageView alloc] initWithImage:image];
        objc_setAssociatedObject(self,
                                 KeyImageView,
                                 view,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return view;
}

-(void)deleteImageView
{
    UIImageView *view = objc_getAssociatedObject(self, KeyImageView);
    if (view && view.superview) {
        [view removeFromSuperview];
        view = nil;
    }
    objc_setAssociatedObject(self,
                             KeyImageView,
                             nil,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIWindow*)closureWindow
{
    UIWindow *window = objc_getAssociatedObject(self, KeyClosureWindow);
    if (window == nil) {
        window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.windowLevel = UIWindowLevelStatusBar + 1;
        window.backgroundColor = [UIColor clearColor];
        objc_setAssociatedObject(self,
                                 KeyClosureWindow,
                                 window,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return window;
}

-(void)deleteClosureWindow
{
    UIWindow *closureWindow = objc_getAssociatedObject(self, KeyClosureWindow);
    if (closureWindow ) {
        closureWindow.hidden = YES;
        NSArray *windows = [[UIApplication sharedApplication] windows];
        NSInteger index = [windows indexOfObject:closureWindow];
        if ( index != NSNotFound && 0 <= index -1 ) {
            UIWindow *window = [windows objectAtIndex:(index-1)];
            [window makeKeyAndVisible];
        }
        closureWindow = nil;
    }
    objc_setAssociatedObject(self,
                             KeyClosureWindow,
                             nil,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


-(UIView*)closureView:(TapCompletion)completion
{
    UIView *view = objc_getAssociatedObject(self, KeyClosureView);
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        view.backgroundColor = [UIColor blackColor];
        view.alpha = 0.5;
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(handleTapGestureRecognizer:)];
        [view addGestureRecognizer:gr];
        if (completion) {
            objc_setAssociatedObject(self,
                                     KeyTapCompletion,
                                     [completion copy],
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        objc_setAssociatedObject(self,
                                 KeyClosureView,
                                 view,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return view;
}

-(void)deleteClosureView
{
    UIView *view = objc_getAssociatedObject(self, KeyClosureView);
    if (view && view.superview) {
        [view removeFromSuperview];
        view = nil;
    }
    objc_setAssociatedObject(self,
                             KeyTapCompletion,
                             nil,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self,
                             KeyClosureView,
                             nil,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@implementation UIViewController (NavigationDrawer)

-(void)setNavigationDrawerWidthScale:(CGFloat)widthScale
{
    if (0 < widthScale && widthScale <= 1.0) {
        objc_setAssociatedObject(self,
                                 KeyWidthScale,
                                 [NSNumber numberWithFloat:widthScale],
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

-(void)presentNavigationDrawer:(UIViewController*)viewController
                      animated:(BOOL)animated
{
    [self presentNavigationDrawer:viewController
                         animated:animated
                       widthScale:[viewController widthScale]
                         fromLeft:true
                 alongCurrentView:false];
}


-(void)presentNavigationDrawer:(UIViewController*)viewController
                      animated:(BOOL)animated
                    widthScale:(CGFloat)widthScale
                       fromLeft:(BOOL)fromLeft
              alongCurrentView:(BOOL)currentView
{
    if (viewController == nil) {
        return;
    }
    
    if ([viewController isDrawing]) {
        return;
    }
    [viewController setIsDrawing:YES];
    
    [viewController setNavigationDrawerWidthScale:widthScale];
    [viewController setFromLeft:fromLeft];
    
    UIImageView *imageView = nil;
    if (currentView) {
        imageView = [viewController imageView];
    }else{
        [viewController deleteImageView];
    }
    
    UIView *closureView = [viewController closureView:^{
        [viewController dismissNavigationDrawerAnimated:true
                                             completion:^(BOOL finished) {
                                             }];
    }];
    
    CGRect starting = [viewController screenRect];
    starting.size.width = (starting.size.width)*[viewController widthScale];
    if ([viewController fromLeft]) {
        starting.origin.x = -(starting.size.width);
    }else{
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        starting.origin.x = screenRect.size.width + (starting.size.width);
    }
    viewController.view.frame = starting;
    
    UIWindow *window = [viewController closureWindow];
    [window makeKeyAndVisible];
    if (imageView) {
        [window addSubview:imageView];
    }
    [window addSubview:closureView];
    [window addSubview:viewController.view];
    
    closureView.alpha = 0.1;
    [UIView animateWithDuration:[viewController timeInterval:animated]
                     animations:^{
                         
                         CGRect finished = viewController.view.frame;
                         if ([viewController fromLeft]) {
                             finished.origin.x = 0;
                         }else{
                             CGRect screenRect = [[UIScreen mainScreen] bounds];
                             finished.origin.x = screenRect.size.width - (starting.size.width);
                         }
                         viewController.view.frame = finished;
                         
                         if (imageView) {
                             CGRect ivRect = imageView.frame;
                             if ([viewController fromLeft]) {
                                 ivRect.origin.x = viewController.view.frame.size.width;
                             }else{
                                 ivRect.origin.x = -viewController.view.frame.size.width;
                             }
                             imageView.frame = ivRect;
                         }
                         
                         closureView.alpha = 0.5;
                         
                     } completion:^(BOOL finished) {
                     }];
}

-(void)dismissNavigationDrawerAnimated:(BOOL)animated
                            completion:(void (^)(BOOL finished))completion
{
    if ( [self isDrawing] ) {
        
        UIView *closureView = [self closureView:nil];
        UIImageView *imageView = [self imageView];
        
        [UIView animateWithDuration:[self timeInterval:animated]
                         animations:^{
                             
                             CGRect finished = self.view.frame;
                             if ([self fromLeft]) {
                                 finished.origin.x = -(finished.size.width);
                             }else{
                                 CGRect screenRect = [[UIScreen mainScreen] bounds];
                                 finished.origin.x = screenRect.size.width;
                             }
                             self.view.frame = finished;
                             
                             if (imageView) {
                                 CGRect rect = imageView.frame;
                                 if ([self fromLeft]) {
                                     rect.origin.x = 0;
                                 }else{
                                     rect.origin.x = 0;
                                 }
                                 imageView.frame = rect;
                             }
                             
                             closureView.alpha = 0.1;
                             
                         } completion:^(BOOL finished) {
                             [self deleteImageView];
                             [self deleteClosureView];
                             [self.view removeFromSuperview];
                             [self deleteClosureWindow];
                             [self setIsDrawing:NO];
                             
                             if (completion) {
                                 completion(finished);
                             }
                         }];
    }

}



#pragma mark - 以下削除対象

-(BOOL)isPresentingNavigationDrawer
{
    return [self isDrawing];
}

-(void)presentNavigationDrawer:(BOOL)animated
{
    return [self presentNavigationDrawer:animated
                          withBackground:YES];
}

-(void)presentNavigationDrawer:(BOOL)animated withBackground:(BOOL)screenshot;
{
    if ([self isDrawing]) {
        return;
    }
    [self setIsDrawing:YES];
    
    UIImageView *imageView = nil;
    if (screenshot) {
        imageView = [self imageView];
    }else{
        [self deleteImageView];
    }
        
    UIView *closureView = [self closureView:^{
        [self removeNavigationDrawer:YES];
    }];
    
    CGRect starting = [self screenRect];
    starting.size.width = (starting.size.width)*[self widthScale];
    starting.origin.x = -(starting.size.width);
    self.view.frame = starting;
    
    UIWindow *window = [self closureWindow];
    [window makeKeyAndVisible];
    if (imageView) {
        [window addSubview:imageView];
    }
    [window addSubview:closureView];
    [window addSubview:self.view];
    
    closureView.alpha = 0.1;
    [UIView animateWithDuration:[self timeInterval:animated]
                     animations:^{
                         
                         CGRect finished = self.view.frame;
                         finished.origin.x = 0;
                         self.view.frame = finished;
                         
                         if (imageView) {
                             CGRect ivRect = imageView.frame;
                             ivRect.origin.x = self.view.frame.size.width;
                             imageView.frame = ivRect;                             
                         }
                         
                         closureView.alpha = 0.5;
                         
                     } completion:^(BOOL finished) {
                     }];

}

-(void)removeNavigationDrawer:(BOOL)animated
{
    if ( [self isDrawing] ) {
        
        UIView *closureView = [self closureView:nil];
        UIImageView *imageView = [self imageView];
        
        [UIView animateWithDuration:[self timeInterval:animated]
                         animations:^{
                             
                             CGRect finished = self.view.frame;
                             finished.origin.x = -(finished.size.width);
                             self.view.frame = finished;
                             
                             if (imageView) {
                                 CGRect rect = imageView.frame;
                                 rect.origin.x = 0;
                                 imageView.frame = rect;
                             }
                             
                             closureView.alpha = 0.1;
                             
                         } completion:^(BOOL finished) {
                             [self deleteImageView];
                             [self deleteClosureView];
                             [self.view removeFromSuperview];
                             [self deleteClosureWindow];
                             [self setIsDrawing:NO];
                         }];
    }
}

@end
