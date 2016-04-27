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
    MEOHardwareUtilRemoteControlToggle,
    MEOHardwareUtilRemoteControlPlay,
    MEOHardwareUtilRemoteControlPause,
    MEOHardwareUtilRemoteControlPrevious,
    MEOHardwareUtilRemoteControlNext,
};


extern NSString *const MEOHardwareUtilKeyHeadphones;
extern NSString *const MEOHardwareUtilKeyRemoteControl;

/**
 *  イヤフォンイベントの通知メッセージ
 */
extern NSString *const MEOHardwareUtilDidChangedHeadphones;

/**
 *  リモコンイベントの通知メッセージ
 */
extern NSString *const MEOHardwareUtilDidChangeRemoteControl;


@protocol MEOHardwareUtilDelegate <NSObject>

@optional

- (void)hardwareUtil:(MEOHardwareUtil*)hardwareUtil didChangedHeadphones:(BOOL)hasHeadphones;

- (void)hardwareUtil:(MEOHardwareUtil*)hardwareUtil didChangeRemoteControl:(MEOHardwareUtilRemoteControl)ctrl;

@end

/**
 *  ハードウェア関連のユーティリティ
 */
@interface MEOHardwareUtil : NSObject

@property (nonatomic, weak) id<MEOHardwareUtilDelegate> delegate;

/**
 *  アプリ内通知で送られたuserInfoからヘッドフォン有無を取得する
 */
+ (BOOL)hasHeadphonesFromUserInfo:(NSDictionary*)userInfo;

/**
 *  アプリ内通知で送られたuserInfoからイベント種類を取得する
 */
+ (MEOHardwareUtilRemoteControl)ctrlFromUserInfo:(NSDictionary*)userInfo;


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
