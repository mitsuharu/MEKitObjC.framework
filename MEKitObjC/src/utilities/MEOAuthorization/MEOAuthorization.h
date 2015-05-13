//
//  MEOAuthorization.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2014/10/30.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

/**
 It is an error code of MEOAuthorization
 */
typedef NS_ENUM(NSInteger, MEOAuthorizationErrorCode) {
    MEOAuthorizationErrorCodeNone = 0,
    MEOAuthorizationErrorCodeUnknown,
    MEOAuthorizationErrorCodeNetworkFailed,
    MEOAuthorizationErrorCodeAccountNotFound,
    MEOAuthorizationErrorCodePermissionDenied,
};

/**
 It is blocks of MEOAuthorization
 */
typedef void (^MEOAuthorizationCompletion)(ACAccount *account,
                                           NSError *error,
                                           MEOAuthorizationErrorCode errorCode);


typedef void (^MEOAuthorizationRenewCredentials)(BOOL renewed,
                                                 ACAccountCredentialRenewResult renewResult,
                                                 NSError *error);

typedef void (^MEOAuthorizationWithResponse)(NSDictionary *response,
                                             NSError *error,
                                             MEOAuthorizationErrorCode errorCode);


//renewCredentialsForAccount:(ACAccount *)self.facebookAccount
//completion:^(ACAccountCredentialRenewResult renewResult, NSError *error)

/**
 It supports authorization. e.f. facebook, notifications,
 */
@interface MEOAuthorization : NSObject


@property (nonatomic, retain) ACAccountStore *accountStore;
@property (nonatomic, retain) ACAccount *facebookAccount;

#pragma mark - facebook

/*!
 @brief It authorizes a facebook account that is registed on iOS devices.
 
 @param  facebookAppId It is a facebook app id string.
 @param  completion A block is called when authorization is completed.
 
 @return none
 
 @code
 @endcode
 */
+(void)authorizeWithFacebook:(NSString*)facebookAppId
                  completion:(MEOAuthorizationCompletion)completion;

/*!
 @brief It authorizes a facebook account that is registed on iOS devices.
 
 @param  facebookAppId It is a facebook app id string.
 @param  completion A block is called when authorization is completed.
 @param  audience It is an "audience" string. If nil, audience is "ACFacebookAudienceOnlyMe".
 @param  permissions It is "permissions" array. If nil, permission is "email" only.
 
 @return none
 
 @code
 @endcode
 */
+(void)authorizeWithFacebook:(NSString*)facebookAppId
                    audience:(NSString*)audience
                 permissions:(NSArray*)permissions
                  completion:(MEOAuthorizationCompletion)completion;

+(void)requestFacebookGraphPath:(NSString*)graphPath
                         fields:(NSArray*)fields
                     completion:(MEOAuthorizationWithResponse)completion;

+(void)requestFacebookGraphMe:(MEOAuthorizationWithResponse)completion;

#pragma mark - notification


/**
 リモート通知の許可の有無
 */
+(BOOL)isRegisteredForRemoteNotifications;

/**
 通知の初期設定を行う

 1. [application:didFinishLaunchingWithOptions:]で通知許可を申請する
 
 2. 正常完了したら[application:didRegisterUserNotificationSettings:]を受ける
 認証されたら，引数のnotificationSettings.typesが.None以外の値になる．
 
 3. リモート通知をする場合，その場で「registerRemoteNotifications」を呼ぶ
 
 4. [application:didRegisterForRemoteNotificationsWithDeviceToken:]でトークンを取得する
 
 :param: [containsRemoteNotifications] リモート通知をする場合はYES，そうでなければNO
 :returns: void
 */
+(void)registerUserNotifications:(BOOL)containsRemoteNotifications;

/**
 通知許可完了後にリモート通知を設定する
 
 a. iOS8以上
 
 b. 正常完了したら[application:didRegisterUserNotificationSettings:]でよぶ
 
 :param: なし
 :returns: void
 */
+(void)registerRemoteNotifications;

/**
 データ型のdeviceTokenを文字列型に変換する
 
 :param: [deviceToken] NSDate型のdeviceToken
 :returns: NSString型に変換したdeviceToken
 */
+(NSString*)stringWithDeviceToken:(NSData*)deviceToken;


@end
