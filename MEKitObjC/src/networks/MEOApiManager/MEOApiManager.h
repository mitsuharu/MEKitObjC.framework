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


@protocol MEOApiManagerDelegate <NSObject>

@optional
-(void)apiManagerCompleted:(MEOApiManager*)apiManager
                    result:(MEOApiManagerResultStatus)result
                      data:(NSData*)data
                  userInfo:(NSDictionary*)userInfo
                httpStatus:(NSInteger)httpStatus
                     error:(NSError*)error;
@end

@interface MEOApiManager : NSObject

@property (nonatomic, weak) id<MEOApiManagerDelegate> delegate;

/**
 @brief URLリクエストを行う
 
 @param [headerField] headerField @[@"Content-Type":@"application/json"]
 
 @param [httpMethod] httpMethod @"POST"や@"GET"を指定する
 
 */
-(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
      httpBody:(NSString*)httpBody
      userInfo:(NSDictionary*)userInfo
    completion:(MEOApiManagerCompletion)completion  __attribute__((deprecated("クラスメソッドを使ってください")));;

/**
 *  Jsonデータを辞書型配列にパースする
 *
 *  @param jsonData
 *
 *  @return 辞書型配列
 */
-(NSDictionary*)parseJson:(NSData*)jsonData  __attribute__((deprecated("クラスメソッドを使ってください")));;

/**
 *  httpリクエストを行う（bodyは文字列）
 *
 *  @param urlString
 *  @param headerField
 *  @param httpMethod
 *  @param httpBody
 *  @param userInfo
 *  @param completion
 */
+(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
      httpBody:(NSString*)httpBody
      userInfo:(NSDictionary*)userInfo
    completion:(MEOApiManagerCompletion)completion;

/**
 *  httpリクエストを行う（bodyはデータ型）
 *
 *  @param urlString
 *  @param headerField
 *  @param httpMethod
 *  @param httpBodyData
 *  @param userInfo
 *  @param completion
 */
+(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
  httpBodyData:(NSData*)httpBodyData
      userInfo:(NSDictionary*)userInfo
    completion:(MEOApiManagerCompletion)completion;

/**
 *  httpリクエストを行う（bodyは文字列型，ベーシック認証付き）
 *
 *  @param urlString
 *  @param headerField
 *  @param httpMethod
 *  @param httpBody
 *  @param userInfo
 *  @param username
 *  @param password
 *  @param completion
 */
+(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
      httpBody:(NSString*)httpBody
      userInfo:(NSDictionary*)userInfo
      username:(NSString*)username
      password:(NSString*)password
    completion:(MEOApiManagerCompletion)completion;

/**
 *  httpリクエストを行う（bodyはデータ型，ベーシック認証付き）
 *
 *  @param urlString
 *  @param headerField
 *  @param httpMethod
 *  @param httpBodyData
 *  @param userInfo
 *  @param username
 *  @param password
 *  @param completion
 */
+(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
  httpBodyData:(NSData*)httpBodyData
      userInfo:(NSDictionary*)userInfo
      username:(NSString*)username
      password:(NSString*)password
    completion:(MEOApiManagerCompletion)completion;

/**
 *  ダウンロードを行う
 *
 *  @param urlString
 *  @param userInfo
 *  @param completion
 */
+(void)download:(NSString*)urlString
       userInfo:(NSDictionary*)userInfo
     completion:(MEOApiManagerCompletion)completion;

/**
 *  ダウンロードを行う（ベーシック認証付き）
 *
 *  @param urlString
 *  @param userInfo
 *  @param username
 *  @param password
 *  @param completion
 */
+(void)download:(NSString*)urlString
       userInfo:(NSDictionary*)userInfo
       username:(NSString*)username
       password:(NSString*)password
     completion:(MEOApiManagerCompletion)completion;

/**
 *  Jsonデータを辞書型配列にパースする
 *
 *  @param jsonData
 *
 *  @return パースされた辞書型配列
 */
+(NSDictionary*)parseJson:(NSData*)jsonData;


@end
