//
//  UIViewController+Popover.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/02/01.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

#define POPOVER_ANIMATION_DURATION 0.25
#define POPOVER_ANIMATION_DURATION_CLOSE 0.3

@interface UIViewController (Popover)


/**
 @brief ポップオーバー風にviewcontrollerを表示する
 @brief 仕様上，viewControllerのviewサイズを指定する（センタリングは不要，指定無しなら全体の80%のサイズ）
 @brief [親viewcontroller presentPopoverViewController:子viewcontroller ...]
 */
-(void)presentPopoverViewController:(UIViewController*)viewController
                           animated:(BOOL)animated
                         completion:(void (^)(BOOL finished))completion;

/**
 @brief ポップオーバー風にviewcontrollerを表示する
 @brief 仕様上，viewControllerのviewサイズを指定する（センタリングは不要，指定無しなら全体の80%のサイズ）
 @brief [親viewcontroller presentPopoverViewController:子viewcontroller ...]
 */
-(void)presentPopoverViewController:(UIViewController*)viewController
                           viewSize:(CGSize)viewSize
                           animated:(BOOL)animated
                           duration:(NSTimeInterval)duration
                         completion:(void (^)(BOOL finished))completion;

/**
 @brief ポップオーバー風表示を取り除く
 @brief [子viewcontroller dismissPopoverViewControllerAnimated:...]
 */
-(void)dismissPopoverViewControllerAnimated:(BOOL)animated
                                 completion:(void (^)(BOOL finished))completion;


@end
