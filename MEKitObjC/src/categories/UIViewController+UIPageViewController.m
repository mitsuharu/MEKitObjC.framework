//
//  UIViewController+UIPageViewController.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/04/09.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import "UIViewController+UIPageViewController.h"
#import "NSObject+Enhanced.h"

NSString *const keyPageViewController = @"keyPageViewController";
NSString *const keyCurrentPageViewIndex = @"keyCurrentPageViewIndex";
NSString *const keyMinPageViewIndex = @"keyMinPageViewIndex";
NSString *const keyMaxPageViewIndex = @"keyMaxPageViewIndex";

@implementation UIViewController (PageViewController)

UIPageViewController *gPageViewController;

#pragma mark - io

-(UIPageViewController*)pageViewController
{
    return gPageViewController;
}

-(NSInteger)currentPageViewIndex
{
    id obj = [self associatedObjectForKey:keyCurrentPageViewIndex];
    NSNumber *num = nil;
    NSInteger index = 0;
    if (obj && [obj isKindOfClass:[NSNumber class]]) {
        num = (NSNumber*)obj;
        index = [num integerValue];
    }
    return index;
}

-(void)setCurrentPageViewIndex:(NSInteger)currentPageViewIndex
{
    NSInteger tempIndex = [self currentPageViewIndex];
    if (tempIndex != currentPageViewIndex) {
        [self setAssociatedObject:[NSNumber numberWithInteger:currentPageViewIndex]
                           forKey:keyCurrentPageViewIndex];
        if ([self respondsToSelector:@selector(meoPageViewController:changedCurrentPageViewIndex:)]
            && [self conformsToProtocol:@protocol(MEOPageViewControllerProtocol)]) {
            [(id<MEOPageViewControllerProtocol>)self meoPageViewController:[self pageViewController]
                                               changedCurrentPageViewIndex:currentPageViewIndex];
        }
    }
}


-(NSInteger)minPageViewIndex
{
    id obj = [self associatedObjectForKey:keyMinPageViewIndex];
    NSNumber *num = nil;
    NSInteger index = 0;
    if (obj && [obj isKindOfClass:[NSNumber class]]) {
        num = (NSNumber*)obj;
        index = [num integerValue];
    }
    return index;
}

-(void)setMinPageViewIndex:(NSInteger)minPageViewIndex
{
    [self setAssociatedObject:[NSNumber numberWithInteger:minPageViewIndex]
                       forKey:keyMinPageViewIndex];
}

-(NSInteger)maxPageViewIndex
{
    id obj = [self associatedObjectForKey:keyMaxPageViewIndex];
    NSNumber *num = nil;
    NSInteger index = 10;
    if (obj && [obj isKindOfClass:[NSNumber class]]) {
        num = (NSNumber*)obj;
        index = [num integerValue];
    }
    return index;
}

-(void)setMaxPageViewIndex:(NSInteger)maxPageViewIndex
{
    [self setAssociatedObject:[NSNumber numberWithInteger:maxPageViewIndex]
                       forKey:keyMaxPageViewIndex];
}


#pragma mark - help UIPageViewController

-(BOOL)addPageViewControllerWithIndex:(NSInteger)index
{
    return [self addPageViewControllerWithIndex:index
                                  atView:self.view
                       transitionStyle:UIPageViewControllerTransitionStyleScroll
                 navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal];
}

-(BOOL)addPageViewControllerWithIndex:(NSInteger)index
                        atView:(UIView*)view
{
    return [self addPageViewControllerWithIndex:index
                                  atView:view
                       transitionStyle:UIPageViewControllerTransitionStyleScroll
                 navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal];
}

-(BOOL)addPageViewControllerWithIndex:(NSInteger)index
                        atView:(UIView*)view
             transitionStyle:(UIPageViewControllerTransitionStyle)transitionStyle
       navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation
{
    BOOL result = false;
    
    UIViewController *viewController = nil;
    if ([self respondsToSelector:@selector(meoPageViewController:viewControllerAtPageViewIndex:)]
        && [self conformsToProtocol:@protocol(MEOPageViewControllerProtocol)]) {
        viewController = [(id<MEOPageViewControllerProtocol>)self meoPageViewController:[self pageViewController]
                                                          viewControllerAtPageViewIndex:index];
    }
    
    if (viewController == nil) {
        return result;
    }
    
    if (gPageViewController && gPageViewController.view.superview != nil) {
    }else{
        result = true;
        gPageViewController = [[UIPageViewController alloc] initWithTransitionStyle:transitionStyle
                                              navigationOrientation:navigationOrientation
                                                            options:nil];
        gPageViewController.delegate = self;
        gPageViewController.dataSource = self;
        gPageViewController.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
        
        [self addChildViewController:gPageViewController];
        
        [gPageViewController setViewControllers:@[viewController]
                      direction:UIPageViewControllerNavigationDirectionForward
                       animated:0.5
                     completion:^(BOOL finished) {
                                     }];
        
        
        for (UIGestureRecognizer* gestureRecognizer in gPageViewController.gestureRecognizers) {
            if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
                gestureRecognizer.enabled = NO;
            }
        }
        
        [view addSubview:gPageViewController.view];
        [gPageViewController didMoveToParentViewController:self];
        
     //   [self setPageViewController:pvc];
    }
    
    return result;
}

-(void)removePageViewController
{
    if (gPageViewController) {
        if (gPageViewController.view.superview != nil) {
            [gPageViewController.view removeFromSuperview];
        }
        
        if ([gPageViewController parentViewController]) {
            [gPageViewController removeFromParentViewController];
        }
        
        gPageViewController.delegate = nil;
        gPageViewController.dataSource = nil;
    }
    gPageViewController = nil;
}

-(void)showViewControllerAtPageViewIndex:(NSInteger)index
                                animeted:(BOOL)animeted
                              completion:(void (^)(BOOL finished))completion
{
    UIPageViewController *pvc = [self pageViewController];
    NSInteger currentPageViewIndex = [self currentPageViewIndex];
    
    if (pvc == nil
        || currentPageViewIndex == index
        || !([self minPageViewIndex] <= index && index < [self maxPageViewIndex])) {
        if (completion) {
            completion(false);
        }
        return;
    }
    
    UIViewController *viewController = nil;
    if ([self respondsToSelector:@selector(meoPageViewController:viewControllerAtPageViewIndex:)]
        && [self conformsToProtocol:@protocol(MEOPageViewControllerProtocol)]) {
        viewController = [(id<MEOPageViewControllerProtocol>)self meoPageViewController:[self pageViewController]
                                                          viewControllerAtPageViewIndex:index];
    }
    if (viewController == nil) {
        if (completion) {
            completion(false);
        }
        return;
    }
    
    void (^block)(BOOL finished) = [completion copy];
    
    // ページ捲りの向き
    UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
    if (index < currentPageViewIndex) {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    
    currentPageViewIndex = index;
    [self setCurrentPageViewIndex:index];
    
    [pvc setViewControllers:@[viewController]
                  direction:direction
                   animated:animeted
                 completion:^(BOOL finished){
                     if (block) {
                         block(finished);
                     }
                 }];
}


#pragma mark - UIPageViewControllerDelegate


- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    if ((completed) || (!completed && finished)) {
        UIViewController *presentVC = pageViewController.viewControllers.firstObject;
        NSInteger index  = [self currentPageViewIndex];
        if ([self respondsToSelector:@selector(meoPageViewController:pageViewIndexOfViewController:)]
            && [self conformsToProtocol:@protocol(MEOPageViewControllerProtocol)]) {
            index = [(id<MEOPageViewControllerProtocol>)self meoPageViewController:[self pageViewController]
                                                     pageViewIndexOfViewController:presentVC];
        }
        [self setCurrentPageViewIndex:index];
    }else{
    }
}


#pragma mark - UIPageViewControllerDataDelegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index  = [self currentPageViewIndex];
    if ([self respondsToSelector:@selector(meoPageViewController:pageViewIndexOfViewController:)]
        && [self conformsToProtocol:@protocol(MEOPageViewControllerProtocol)]) {
        index = [(id<MEOPageViewControllerProtocol>)self meoPageViewController:[self pageViewController]
                                                 pageViewIndexOfViewController:viewController];
    }
    NSInteger index2 = index-1;
    
    UIViewController *vc = nil;
    if ([self minPageViewIndex] <= index2 && index2 < [self maxPageViewIndex]) {
        if ([self respondsToSelector:@selector(meoPageViewController:viewControllerAtPageViewIndex:)]
            && [self conformsToProtocol:@protocol(MEOPageViewControllerProtocol)]) {
            vc = [(id<MEOPageViewControllerProtocol>)self meoPageViewController:[self pageViewController]
                                                  viewControllerAtPageViewIndex:index2];
        }
    }

    return vc;
}

-(UIViewController*)pageViewController:(UIPageViewController *)pageViewController
     viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index  = [self currentPageViewIndex];
    if ([self respondsToSelector:@selector(meoPageViewController:pageViewIndexOfViewController:)]
        && [self conformsToProtocol:@protocol(MEOPageViewControllerProtocol)]) {
        index = [(id<MEOPageViewControllerProtocol>)self meoPageViewController:[self pageViewController]
                                                 pageViewIndexOfViewController:viewController];
    }
    NSInteger index2 = index+1;

    UIViewController *vc = nil;
    if ([self minPageViewIndex] <= index2 && index2 < [self maxPageViewIndex]) {
        if ([self respondsToSelector:@selector(meoPageViewController:viewControllerAtPageViewIndex:)]
            && [self conformsToProtocol:@protocol(MEOPageViewControllerProtocol)]) {
            vc = [(id<MEOPageViewControllerProtocol>)self meoPageViewController:[self pageViewController]
                                                  viewControllerAtPageViewIndex:index2];
        }
    }
    
    return vc;
}

@end
