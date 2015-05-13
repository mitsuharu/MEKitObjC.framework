//
//  UIViewController+NavigationDrawer.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/01/13.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (NavigationDrawer)

-(void)setNavigationDrawerWidthScale:(CGFloat)widthScale;

-(BOOL)isPresentingNavigationDrawer;

-(void)presentNavigationDrawer:(BOOL)animated;

/**
 @brief ナビゲーションドロワーとして表示する
 @param [animated] animated 表示アニメーションの有無
 @param [background] background ドロワー表示時に背景ビューも一緒に動かす場合はYES，それ以外はNO
 */
-(void)presentNavigationDrawer:(BOOL)animated withBackground:(BOOL)background;

-(void)removeNavigationDrawer:(BOOL)animated;

@end
