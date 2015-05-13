//
//  UIScrollView+Enhanced.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/03/20.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (Enhanced)

/**
 @brief スクロールが止まっているか判定する
 @return YESならば止まっている，NOなら動いている
 */
-(BOOL)isScrollStopped;

@end
