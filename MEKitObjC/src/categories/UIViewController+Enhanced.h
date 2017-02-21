//
//  UIViewController+Enhanced.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/11/08.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Enhanced)

/**
 @brief 最も前面にあるViewControllerを取得する
 @return UIViewControllerのインスタンス
 */
+(UIViewController*)topLayerViewController;

/**
 @brief "className"というStoryboardから"className"というidentifierのUIViewControllerを生成する
 */
+(UIViewController*)instantiateWithStoryboard;

+(UIViewController*)instantiateWithStoryboard:(NSString*)storyboard;

+(UIViewController*)instantiateWithStoryboard:(NSString*)storyboard
                                   identifier:(NSString*)identifier;



/**
 *  UIViewControllerが表示されているか判定
 */
- (BOOL)meo_isVisible;


@end

#pragma mark - Keyboard

@interface MEOKeyboard : NSObject
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) UIViewAnimationCurve curve;
@property (nonatomic, assign) UIViewAnimationOptions opt;
- (instancetype)initWithNotification:(NSNotification*)notification;
@end

@protocol MEOKeyboardNotification <NSObject>

@required
-(void)meoKeyboardWillShow:(NSNotification*)notification;
-(void)meoKeyboardWillHide:(NSNotification*)notification;

@optional
-(void)meoKeyboardDidShow:(NSNotification*)notification;
-(void)meoKeyboardDidHide:(NSNotification*)notification;

@end


@interface UIViewController (Keyboard)

-(void)addKeyboardNotification;
-(void)removeKeyboardNotification;
-(CGRect)keyboardRect:(NSNotification*)notification;
-(NSTimeInterval)keyboardDuration:(NSNotification*)notification;
-(UIViewAnimationCurve)keyboardCurve:(NSNotification*)notification;

@end

@interface UIViewController (NavigationControllerSwipeTransition)

-(void)disableNavigationControllerSwipeTransition;

@end
