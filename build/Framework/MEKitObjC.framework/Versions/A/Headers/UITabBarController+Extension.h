//
//  UITabBarController+Extension.h
//  BramoDemo
//
//  Created by Mitsuharu Emoto on 2014/12/25.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarController (Extension)


/**
 @brief タブバーの非表示を行う
 
 ナビゲーションバーも同時消しの場合
 [self.tabBarController hideTabBar:YES animated:YES];
 [self.navigationController setNavigationBarHidden:YES animated:YES];
 */
-(void)hideTabBar:(BOOL)hidden animated:(BOOL)animated;

@end
