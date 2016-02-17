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

@property (nonatomic, assign) BOOL ignoreCacheData;
@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSDictionary *userInfo;

@end


#pragma mark - MEOApiManager

@interface MEOApiManager : NSObject

/**
 *  Jsonデータをパースして辞書列配列で返す
 *
 *  @param jsonData
 *
 *  @return 辞書列配列
 */
+(NSDictionary*)parseJson:(NSData*)jsonData;


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
 *  ダウンロードする
 *
 *  @param urlString
 *  @param option
 *  @param completion
 */
+(void)download:(NSString*)urlString
         option:(MEOApiOption*)option
     completion:(MEOApiManagerCompletion)completion;

// 以下，削除します

+(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
      httpBody:(NSString*)httpBody
      userInfo:(NSDictionary*)userInfo
    completion:(MEOApiManagerCompletion)completion __attribute__((deprecated("付加情報をoptionクラスで指定に変更する")));

+(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
  httpBodyData:(NSData*)httpBodyData
      userInfo:(NSDictionary*)userInfo
    completion:(MEOApiManagerCompletion)completion __attribute__((deprecated("付加情報をoptionクラスで指定に変更する")));

+(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
      httpBody:(NSString*)httpBody
      userInfo:(NSDictionary*)userInfo
      username:(NSString*)username
      password:(NSString*)password
    completion:(MEOApiManagerCompletion)completion __attribute__((deprecated("付加情報をoptionクラスで指定に変更する")));

+(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
  httpBodyData:(NSData*)httpBodyData
      userInfo:(NSDictionary*)userInfo
      username:(NSString*)username
      password:(NSString*)password
    completion:(MEOApiManagerCompletion)completion __attribute__((deprecated("付加情報をoptionクラスで指定に変更する")));

+(void)download:(NSString*)urlString
       userInfo:(NSDictionary*)userInfo
     completion:(MEOApiManagerCompletion)completion __attribute__((deprecated("付加情報をoptionクラスで指定に変更する")));

+(void)download:(NSString*)urlString
       userInfo:(NSDictionary*)userInfo
       username:(NSString*)username
       password:(NSString*)password
     completion:(MEOApiManagerCompletion)completion __attribute__((deprecated("付加情報をoptionクラスで指定に変更する")));

@end
