//
//  MEOApiManager.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2014/10/25.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class MEOApiManager;

extern NSString* const MEOApiManagerHttpMethodPost;
extern NSString* const MEOApiManagerHttpMethodPut;
extern NSString* const MEOApiManagerHttpMethodGet;
extern NSString* const MEOApiManagerHttpMethodDelete;
extern NSString* const MEOApiManagerHttpMethodPatch;
//extern NSString* const MEOApiManagerHttpMethodHEAD;
//extern NSString* const MEOApiManagerLastModified;

typedef enum {
    MEOApiManagerResultStatusNetworkFailed = 0,
    MEOApiManagerResultStatusRequestFailed,
    MEOApiManagerResultStatusResponseFailed,
    MEOApiManagerResultStatusResponseSucsess,
}MEOApiManagerResultStatus;

typedef void (^MEOApiManagerCompletion) (MEOApiManagerResultStatus result,
                                         NSData* data,
                                         NSDictionary *userInfo,
                                         NSInteger httpStatus,
                                         NSError *error);

#pragma mark - MEOApiOption

@interface MEOApiOption : NSObject

/**
 通信中のネットワークインジケーターを表示する場合はtrue, そうで無い場合はfalse（初期値false）
 */
@property (nonatomic, assign) BOOL hideNetworkActivityIndicator;


@property (nonatomic, assign) BOOL ignoreCacheData;
@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;

/**
 *  Basic認証
 */
@property (nonatomic, retain) NSString *username;

/**
 *  Basic認証
 */
@property (nonatomic, retain) NSString *password;

@property (nonatomic, retain) NSDictionary *userInfo;


@property (nonatomic, assign) BOOL comparelastModified;

@end


#pragma mark - MEOApiManager

@interface MEOApiManager : NSObject


- (BOOL)cancel;

- (void)request:(NSString*)urlString
    headerField:(NSDictionary*)headerField
     httpMethod:(NSString*)httpMethod
   httpBodyData:(NSData*)httpBodyData
         option:(MEOApiOption*)option
     completion:(MEOApiManagerCompletion)completion;

- (void)request:(NSString*)urlString
    headerField:(NSDictionary*)headerField
     httpMethod:(NSString*)httpMethod
httpBodyJsonDict:(NSDictionary*)JsonDict
         option:(MEOApiOption*)option
     completion:(MEOApiManagerCompletion)completion;

- (void)request:(NSString*)urlString
    headerField:(NSDictionary*)headerField
     httpMethod:(NSString*)httpMethod
       httpBody:(NSString*)httpBody
         option:(MEOApiOption*)option
     completion:(MEOApiManagerCompletion)completion;

- (void)download:(NSString*)urlString
          option:(MEOApiOption*)option
      completion:(MEOApiManagerCompletion)completion;

- (void)requestLastModified:(NSString*)urlString
                     option:(MEOApiOption*)option
                 completion:(MEOApiManagerCompletion)completion;


/**
 *  Jsonデータをパースして辞書列配列で返す
 *
 *  @param jsonData
 *
 *  @return 辞書列配列
 */
+(NSDictionary*)parseJson:(NSData*)jsonData;

/**
 *  Jsonデータをパースしてオブジェクトで返す
 *
 *  @param jsonData
 *
 *  @return オブジェクト
 */
+ (id)parsedJsonObj:(NSData*)jsonData;

/**
 *  Jsonデータをパースして辞書列配列で返す
 *
 *  @param jsonData
 *
 *  @return 辞書列配列
 */
+ (NSDictionary*)parsedJsonDictionary:(NSData*)jsonData;

/**
 *  Jsonデータをパースして配列で返す
 *
 *  @param jsonData
 *
 *  @return 配列
 */
+ (NSArray*)parsedJsonArray:(NSData*)jsonData;


/**
 *  UserInfoからlastModifiedを取得する
 *
 *  @param userInfo リクエストメソッドから取得される
 *
 *  @return ファイルの更新日時，なければnil
 */
+ (NSDate*)lastModified:(NSDictionary*)userInfo;

/**
 *  httpリクエストを行う（bodyは文字列）
 *
 *  @param urlString
 *  @param headerField
 *  @param httpMethod
 *  @param httpBody
 *  @param option
 *  @param completion
 */
+(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
      httpBody:(NSString*)httpBody
        option:(MEOApiOption*)option
    completion:(MEOApiManagerCompletion)completion;

/**
 *  httpリクエストを行う（bodyはデータ型）
 *
 *  @param urlString
 *  @param headerField
 *  @param httpMethod
 *  @param httpBodyData
 *  @param option
 *  @param completion
 */
+(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
  httpBodyData:(NSData*)httpBodyData
        option:(MEOApiOption*)option
    completion:(MEOApiManagerCompletion)completion;

/**
 *  httpリクエストを行う（bodyはJson連想配列）
 *
 *  @param urlString
 *  @param headerField
 *  @param httpMethod
 *  @param JsonDict
 *  @param option
 *  @param completion
 */
+(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
httpBodyJsonDict:(NSDictionary*)JsonDict
        option:(MEOApiOption*)option
    completion:(MEOApiManagerCompletion)completion;

/**
 *  ダウンロードする
 *
 *  @param urlString
 *  @param option
 *  @param completion
 *
 更新日時は完了ブロックのuserInfoから取得する．
 @code
 NSDate *lastModified = [MEOApiManager lastModified:userInfo];
 @endcode
 */
+(void)download:(NSString*)urlString
         option:(MEOApiOption*)option
     completion:(MEOApiManagerCompletion)completion;


/**
 *  対象の更新日時だけを取得する（データはダウンロードは行わない，更新日時取得は常に行っている）
 *
 更新日時は完了ブロックのuserInfoから取得する．
 @code
 NSDate *lastModified = [MEOApiManager lastModified:userInfo];
 @endcode
 */
+ (void)requestLastModified:(NSString*)urlString
                     option:(MEOApiOption*)option
                 completion:(MEOApiManagerCompletion)completion;


//// 以下，削除します
//
//+(void)request:(NSString*)urlString
//   headerField:(NSDictionary*)headerField
//    httpMethod:(NSString*)httpMethod
//      httpBody:(NSString*)httpBody
//      userInfo:(NSDictionary*)userInfo
//    completion:(MEOApiManagerCompletion)completion __attribute__((deprecated("付加情報をoptionクラスで指定に変更する")));
//
//+(void)request:(NSString*)urlString
//   headerField:(NSDictionary*)headerField
//    httpMethod:(NSString*)httpMethod
//  httpBodyData:(NSData*)httpBodyData
//      userInfo:(NSDictionary*)userInfo
//    completion:(MEOApiManagerCompletion)completion __attribute__((deprecated("付加情報をoptionクラスで指定に変更する")));
//
//+(void)request:(NSString*)urlString
//   headerField:(NSDictionary*)headerField
//    httpMethod:(NSString*)httpMethod
//      httpBody:(NSString*)httpBody
//      userInfo:(NSDictionary*)userInfo
//      username:(NSString*)username
//      password:(NSString*)password
//    completion:(MEOApiManagerCompletion)completion __attribute__((deprecated("付加情報をoptionクラスで指定に変更する")));
//
//+(void)request:(NSString*)urlString
//   headerField:(NSDictionary*)headerField
//    httpMethod:(NSString*)httpMethod
//  httpBodyData:(NSData*)httpBodyData
//      userInfo:(NSDictionary*)userInfo
//      username:(NSString*)username
//      password:(NSString*)password
//    completion:(MEOApiManagerCompletion)completion __attribute__((deprecated("付加情報をoptionクラスで指定に変更する")));
//
//+(void)download:(NSString*)urlString
//       userInfo:(NSDictionary*)userInfo
//     completion:(MEOApiManagerCompletion)completion __attribute__((deprecated("付加情報をoptionクラスで指定に変更する")));
//
//+(void)download:(NSString*)urlString
//       userInfo:(NSDictionary*)userInfo
//       username:(NSString*)username
//       password:(NSString*)password
//     completion:(MEOApiManagerCompletion)completion __attribute__((deprecated("付加情報をoptionクラスで指定に変更する")));

@end
