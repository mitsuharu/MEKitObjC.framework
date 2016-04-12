//
//  UIViewController+HeadphoneNotification.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2016/04/07.
//  Copyright © 2016年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 *  リモコンの制御イベント
 */
typedef NS_ENUM(NSInteger, MEORemoteControlEvent) {
    /**
     *  不明イベント
     */
    MEORemoteControlEventNone = 0,
    /**
     *  再生と停止のトグルボタン
     */
    MEORemoteControlEventTogglePlayPause,
    /**
     *  再生
     */
    MEORemoteControlEventPlay,
    /**
     *  停止
     */
    MEORemoteControlEventPause,
    /**
     *  前に戻る
     */
    MEORemoteControlEventPreviousTrack,
    /**
     *  次に進む
     */
    MEORemoteControlEventNextTrack,
};


/**
 *  ヘッドホン（イヤホンマイク）関連のイベントを受ける
 */
@protocol MEOHeadphoneNotification <NSObject>

@optional

/**
 *  ヘッドホン（イヤホン）が差し抜きされたときに呼ばれる
 *
 *  @param hasHeadphone ヘッドホンが差してあるときtrue, それ以外はfalse
 */
- (void)meoHeadphoneChanged:(BOOL)hasHeadphone;

/**
 *  リモコンの制御ボタンが押されたときにイベントを通知する
 *
 *  @param ctrl リモコンの制御イベント
 */
- (void)meoRemoteControlEventChanged:(MEORemoteControlEvent)event;

@end


@interface UIViewController (HeadphoneNotification)


/**
 *  ヘッドホンを指している場合にtrue，それ以外はfalseを返す
 */
- (BOOL)hasHeadphone;

/**
 *  イベントが再生停止トグルか再生か停止のときにtrue, それ以外はfalse
 */
- (BOOL)isTogglePlayPause:(MEORemoteControlEvent)event;

/**
 * ヘッドホンとリモコンの状態監視を開始する
 *
 * [注意] iOS7.0.*対応の場合，リモコンの状態を監視するには"canBecomeFirstResponder"を以下のように上書きする
 * @code
 - (BOOL)canBecomeFirstResponder{
    return true;
 }@endcode
 */
- (void)addHeadphoneNotification;


/**
 * ヘッドホンとリモコンの状態監視を終了する
 */
- (void)removeHeadphoneNotification;


@end
