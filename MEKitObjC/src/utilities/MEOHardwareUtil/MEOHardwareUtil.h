//
//  MEOHardwareUtil.h
//  HardwareCtrl
//
//  Created by Mitsuharu Emoto on 2016/04/07.
//  Copyright © 2016年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MEOHardwareUtil;



/**
 *  リモコンの制御イベント
 */
typedef NS_ENUM(NSInteger, MEOHardwareUtilRemoteControl) {
    MEOHardwareUtilRemoteControlNone = 0,
    MEOHardwareUtilRemoteControlTogglePlayPause,
    MEOHardwareUtilRemoteControlPlay,
    MEOHardwareUtilRemoteControlPause,
    MEOHardwareUtilRemoteControlPreviousTrack,
    MEOHardwareUtilRemoteControlNextTrack,
};



@protocol MEOHardwareUtilDelegate <NSObject>

@optional

- (void)hardwareUtil:(MEOHardwareUtil*)hardwareUtil didChangedHeadphone:(BOOL)hasHeadphone;

- (void)hardwareUtil:(MEOHardwareUtil*)hardwareUtil didChangeRemoteControl:(MEOHardwareUtilRemoteControl)ctrl;

@end

/**
 *  ハードウェア関連のユーティリティ
 */
@interface MEOHardwareUtil : NSObject

@property (nonatomic, weak) id<MEOHardwareUtilDelegate> delegate;

/**
 *  端末にヘッドフォンが刺さっているか確認する
 */
+ (BOOL)hasHeadphones;

/**
 *  ヘッドフォンイベントの補助関数
 */
+ (BOOL)isTogglePlayPause:(MEOHardwareUtilRemoteControl)ctrl;

/**
 *  ヘッドフォンの差し抜きおよびボタンイベントを監視する
 *  （ボタンイベントはiOS7.1以上のみ）
 */
- (void)addHeadphoneNotification;

/**
 *  ヘッドフォン監視を終了する
 */
- (void)removeHeadphoneNotification;


@end
