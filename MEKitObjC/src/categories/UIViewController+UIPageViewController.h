//
//  UIViewController+UIPageViewController.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/04/09.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 UIPageViewController向けの補助クラスのプロトコル
 */
@protocol MEOPageViewControllerProtocol <NSObject>

@required

-(UIViewController*)meoPageViewController:(UIPageViewController *)pageViewController
            viewControllerAtPageViewIndex:(NSInteger)index;

-(NSInteger)meoPageViewController:(UIPageViewController *)pageViewController
        pageViewIndexOfViewController:(UIViewController*)viewController;

@optional

-(void)meoPageViewController:(UIPageViewController *)pageViewController
    changedCurrentPageViewIndex:(NSInteger)currentPageViewIndex;


@end


/**
 UIPageViewController向けの補助クラス
 */
@interface UIViewController (PageViewController)
<
    UIPageViewControllerDelegate,
    UIPageViewControllerDataSource
>

-(UIPageViewController*)pageViewController;
-(void)setPageViewController:(UIPageViewController*)pageViewController;

-(NSInteger)currentPageViewIndex;
-(void)setCurrentPageViewIndex:(NSInteger)currentPageViewIndex;

-(NSInteger)minPageViewIndex;
-(void)setMinPageViewIndex:(NSInteger)minPageViewIndex;

-(NSInteger)maxPageViewIndex;
-(void)setMaxPageViewIndex:(NSInteger)maxPageViewIndex;


-(BOOL)addPageViewControllerWithIndex:(NSInteger)index;
-(BOOL)addPageViewControllerWithIndex:(NSInteger)index
                                     atView:(UIView*)view;
-(BOOL)addPageViewControllerWithIndex:(NSInteger)index
                                     atView:(UIView*)view
                            transitionStyle:(UIPageViewControllerTransitionStyle)transitionStyle
                      navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation;

-(void)removePageViewController;

-(void)showViewControllerAtPageViewIndex:(NSInteger)index
                                animeted:(BOOL)animeted
                              completion:(void (^)(BOOL finished))completion;

@end
