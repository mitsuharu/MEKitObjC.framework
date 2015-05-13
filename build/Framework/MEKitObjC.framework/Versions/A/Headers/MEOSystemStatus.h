//
//  SystemStatus.h
//  MEKitObjC
//
//  Created by Emoto Mitsuharu on 11/11/02.
//  Copyright (c) 2011年 Mitsuharu Emoto. All rights reserved.
//

// SystemConfiguration.framework

#import <Foundation/Foundation.h>

@class MEOSystemStatus;

extern const NSString *NotificationNetworkBecomeSuccess;
extern const NSString *NotificationNetworkBecomeFailure;

//#define NotificationNetworkBecomeSuccess @"NotificationNetworkBecomeSuccess"
//#define NotificationNetworkBecomeFailure @"NotificationNetworkBecomeFailure"

/**
 @brief システム状態に関する管理クラスのデリゲード
 */
@protocol MEOSystemStatusDelegate <NSObject>
@optional

/**
 @brief ネットワーク状態が変わったら呼ばれるデリゲードメソッド
 @param [systemStatus] システム状態に関する管理クラスのインスタンス
 @param [rechable] ネットワーク状態の正常ならYES，そうでなければNO
 */
-(void)systemStatus:(MEOSystemStatus*)systemStatus changeReachableStatus:(BOOL)rechable;
@end

typedef void (^ReachableStatusBlock)(BOOL reachabile);


/**
 @brief システム状態に関する管理クラス
 */
@interface MEOSystemStatus : NSObject

@property (nonatomic, weak) id<MEOSystemStatusDelegate> delegate;

//+(id)shareInstance;

-(id)initWithDelegate:(id<MEOSystemStatusDelegate>)delegate;

/**
 @brief ネットワーク状態の監視を始める
 */
-(void)startReachableNotification;


/**
 @brief ネットワーク状態の監視を始める
 @param [targetUrl] 監視対象がある場合はURLを指定する
 @param [reachableStatus] 状態変化をブロックで受け取る
 */
-(void)startReachableNotification:(NSString*)targetUrl
                    completion:(ReachableStatusBlock)reachableStatus;


/**
 @brief ネットワーク状態の監視を止める
 */
-(void)stopReachableNotification;

+(BOOL)displayIs3inch;
+(BOOL)displayIs4inch;

+(NSInteger)versionMajor;
+(NSInteger)versionMinor;

+(NSString *)platform;
+(BOOL)isIphone;
+(BOOL)isIphone3GS;
+(BOOL)isIphone4;
+(BOOL)isIphone4S;

+(BOOL)isIpodTouch;
+(BOOL)isIpodTouch4th;

+(BOOL)isIpad;
+(BOOL)isIpad1;
+(BOOL)isIpad2;

+(BOOL)reachabile;
+(BOOL)reachabileHost:(NSString *)url;
+(BOOL)reachabileInternet;
+(BOOL)reachabileWifi;
+(NSInteger)httpStatusCode:(NSString *)url error:(NSError**)error;

@end
