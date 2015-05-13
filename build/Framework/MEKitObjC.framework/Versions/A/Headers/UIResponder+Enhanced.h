//
//  UIResponder+Enhanced.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/03/27.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @breif It is a notification name that called when user taps status bar.
 */
extern NSString *const kMEOStatusBarTappedNotification;

/**
 @breif It is a protocol that called when user taps status bar.
 */
@protocol MEOStatusBarTappedNotification <NSObject>

@optional
-(void)statusBarTapped:(NSNotification*)notification;

@end

@interface UIResponder (Enhanced)

/**
 @breif It starts notification that status bar is tapped.
 */
-(void)addStatusBarTappedNotification;

/**
 @breif It remove notification that status bar is tapped.
 */
-(void)removeStatusBarTappedNotification;

@end
