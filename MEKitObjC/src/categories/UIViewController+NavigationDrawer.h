//
//  UIViewController+NavigationDrawer.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/01/13.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (NavigationDrawer)

/**
 @brief NavigationDrawer風に表示するviewControllerの幅比率を設定する（任意）
 @parame widthScale 幅比率
 @code
    [navigationDrawer setNavigationDrawerWidthScale:0.6];
 @endcode
 */
-(void)setNavigationDrawerWidthScale:(CGFloat)widthScale;


/**
 @brief NavigationDrawer風にviewControllerを表示する
 @param viewController NavigationDrawerで表示するビューコントローラー
 @param animeted アニメーションで表示するならばtrue，そうでなければfalse
 @code
    [viewcontroller presentPopoverViewController:navigationDrawer animated:true];
 @endcode
 */
-(void)presentNavigationDrawer:(UIViewController*)viewController
                      animated:(BOOL)animated;

/**
 @brief NavigationDrawer風にviewControllerを表示する
 @param viewController NavigationDrawerで表示するビューコントローラー
 @param animeted アニメーションで表示するならばtrue，そうでなければfalse
 @param widthScale 表示する幅比率（0より大きく1未満）
 @param currentView 現在表示されている画面も一緒に移動するならばtrue，そうでなければfalse
 @code
 [viewcontroller presentPopoverViewController:navigationDrawer animated:true widthScale:0.5 alongCurrentView:true];
 @endcode
 */
-(void)presentNavigationDrawer:(UIViewController*)viewController
                      animated:(BOOL)animated
                    widthScale:(CGFloat)widthScale
                      fromLeft:(BOOL)fromLeft
              alongCurrentView:(BOOL)currentView;

/**
 @brief NavigationDrawer表示を取り除く
 @code
 [navigationDrawer dismissNavigationDrawerAnimated:true completion:nil];
 @endcode
 */
-(void)dismissNavigationDrawerAnimated:(BOOL)animated
                            completion:(void (^)(BOOL finished))completion;


#pragma mark - 以下削除する
-(BOOL)isPresentingNavigationDrawer __attribute__((deprecated("")));
-(void)presentNavigationDrawer:(BOOL)animated __attribute__((deprecated("")));
-(void)presentNavigationDrawer:(BOOL)animated
                withBackground:(BOOL)background __attribute__((deprecated("")));
-(void)removeNavigationDrawer:(BOOL)animated __attribute__((deprecated("")));

@end
