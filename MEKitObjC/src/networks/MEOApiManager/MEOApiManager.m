//
//  MEOApiManager.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2014/10/25.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOApiManager.h"
#import "MyReachability.h"

NSString* const MEOApiManagerHttpMethodPost = @"POST";
NSString* const MEOApiManagerHttpMethodPut = @"PUT";
NSString* const MEOApiManagerHttpMethodGet = @"GET";
NSString* const MEOApiManagerHttpMethodDelete = @"DELETE";

@interface MEOApiManager () < NSURLSessionDelegate >
{
    __weak id<MEOApiManagerDelegate> delegate_;
    NSString *username_;
    NSString *password_;
    NSDictionary *userInfo_;
}

-(void)setUsername:(NSString*)username password:(NSString*)password;
-(void)showsNetworkActivityIndicator:(BOOL)visible;

//-(void)setHttpHeaderFields:(NSDictionary*)hfDict;

@end

@implementation MEOApiManager

@synthesize delegate = delegate_;

-(id)init
{
    if (self = [super init]) {
    }
    return self;
}

-(id)initWithDelegate:(id<MEOApiManagerDelegate>)delegate
{
    if (self = [self init]) {
        delegate_ = delegate;
    }
    return self;
}

-(void)setUsername:(NSString*)username
          password:(NSString*)password
{
    username_ = username;
    password_ = password;
}

-(void)dealloc
{
    [self showsNetworkActivityIndicator:false];
}


-(BOOL)reachabile
{
    MyReachability* reach0 = [MyReachability reachabilityForInternetConnection];
    NetworkStatus status0 = [reach0 currentReachabilityStatus];
    BOOL result0 = (status0==NotReachable)?NO:YES;
    
    MyReachability* reach1 = [MyReachability reachabilityForLocalWiFi];
    NetworkStatus status1 = [reach1 currentReachabilityStatus];
    BOOL result1 = (status1==NotReachable)?NO:YES;
    
    return (result0 || result1);
}

-(void)showsNetworkActivityIndicator:(BOOL)visible
{
    UIApplication *app = [UIApplication sharedApplication];
    [app setNetworkActivityIndicatorVisible:visible];
}

-(NSInteger)httpStatusCode:(NSURLResponse*)response
{
    NSHTTPURLResponse *httpUrlResponse = (NSHTTPURLResponse*)response;
    NSInteger statusCode = -1;
    if (httpUrlResponse) {
        statusCode = [httpUrlResponse statusCode];
    }
    return statusCode;
}

-(BOOL)enableDelegate
{
    return (delegate_ && [delegate_ respondsToSelector:@selector(apiManagerCompleted:result:data:userInfo:httpStatus:error:)]);
}

-(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
      httpBody:(NSString*)httpBody
      userInfo:(NSDictionary*)userInfo
    completion:(MEOApiManagerCompletion)completion
{
    [self request:urlString
      headerField:headerField
       httpMethod:httpMethod
     httpBodyData:[httpBody dataUsingEncoding:NSUTF8StringEncoding]
         userInfo:userInfo
       completion:completion];
}

-(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
  httpBodyData:(NSData*)httpBodyData
      userInfo:(NSDictionary*)userInfo
    completion:(MEOApiManagerCompletion)completion
{
    userInfo_ = userInfo;
    
    if (urlString && urlString.length > 0) {
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self enableDelegate]) {
                [delegate_ apiManagerCompleted:self
                                        result:MEOApiManagerResultStatusRequestFailed
                                          data:nil
                                      userInfo:userInfo_
                                    httpStatus:-1
                                         error:nil];
            }
            if (completion) {
                completion(MEOApiManagerResultStatusRequestFailed, nil, userInfo_, -1, nil);
            }
        });
    }
    
    if ([self reachabile] == false) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self enableDelegate]) {
                [delegate_ apiManagerCompleted:self
                                        result:MEOApiManagerResultStatusNetworkFailed
                                          data:nil
                                      userInfo:userInfo_
                                    httpStatus:-1
                                         error:nil];
            }
            if (completion) {
                completion(MEOApiManagerResultStatusNetworkFailed, nil, userInfo_, -1, nil);
            }
        });
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    if (headerField && headerField.allKeys.count > 0) {
//        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        for (NSString *key in headerField.allKeys) {
            [request addValue:[headerField objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    if (httpMethod && httpMethod.length > 0) {
        request.HTTPMethod = httpMethod;
    }else{
        request.HTTPMethod = MEOApiManagerHttpMethodPost;
    }
    request.HTTPBody = httpBodyData;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:self
                                                     delegateQueue:nil];
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self showsNetworkActivityIndicator:false];
            NSInteger statusCode = [self httpStatusCode:response];
            
            MEOApiManagerResultStatus resultStatus = MEOApiManagerResultStatusResponseFailed;
            if ( 0 <= (statusCode-200) && (statusCode-200) < 100) {
                resultStatus = MEOApiManagerResultStatusResponseSucsess;
            }
            
            if (completion) {
                completion(resultStatus, data, userInfo_, statusCode, error);
            }
            if ([self enableDelegate]) {
                [delegate_ apiManagerCompleted:self
                                        result:resultStatus
                                          data:data
                                      userInfo:userInfo_
                                    httpStatus:statusCode
                                         error:error];
            }
        });
    }];
    [task resume];
    [self showsNetworkActivityIndicator:true];
}


-(void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);

//        if([challenge.protectionSpace.host isEqualToString:@"bramo.mobsol.biz"]){
//            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
//        }
    }
}

//ベーシック認証があれば呼ばれる関数
- (void) URLSession:(NSURLSession *)session
               task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
  completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    if ([challenge proposedCredential]) {
    } else if (username_.length > 0 && password_.length > 0){
        // Basic Auth.
        NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengeUseCredential;
        NSURLCredential *credential = [[NSURLCredential alloc] initWithUser:username_
                                                                   password:password_
                                                                persistence:NSURLCredentialPersistenceNone];
        completionHandler(disposition, credential);
    }
}


-(NSDictionary*)parseJson:(NSData*)jsonData
{
    id json = nil;
    if (jsonData) {
        json = [NSJSONSerialization JSONObjectWithData:jsonData
                                               options:NSJSONReadingAllowFragments
                                                 error:nil];
    }
    NSDictionary *jsonDict = nil;
    if (json && [json isKindOfClass:[NSDictionary class]]) {
        jsonDict = (NSDictionary*)json;
    }
    return jsonDict;
}

// MARK: - クラスメソッド

+(NSDictionary*)parseJson:(NSData*)jsonData
{
    id json = nil;
    if (jsonData) {
        json = [NSJSONSerialization JSONObjectWithData:jsonData
                                               options:NSJSONReadingAllowFragments
                                                 error:nil];
    }
    NSDictionary *jsonDict = nil;
    if (json && [json isKindOfClass:[NSDictionary class]]) {
        jsonDict = (NSDictionary*)json;
    }
    
    return jsonDict;
}

+(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
      httpBody:(NSString*)httpBody
      userInfo:(NSDictionary*)userInfo
    completion:(MEOApiManagerCompletion)completion
{
    [MEOApiManager request:urlString
               headerField:headerField
                httpMethod:httpMethod
                  httpBody:httpBody
                  userInfo:userInfo
                  username:nil
                  password:nil
                completion:completion];
}


+(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
      httpBody:(NSString*)httpBody
      userInfo:(NSDictionary*)userInfo
      username:(NSString*)username
      password:(NSString*)password
    completion:(MEOApiManagerCompletion)completion
{
    MEOApiManager *apiManager = [[MEOApiManager alloc] init];
    [apiManager setUsername:username password:password];
    [apiManager request:urlString
            headerField:headerField
             httpMethod:httpMethod
               httpBody:httpBody
               userInfo:userInfo
             completion:completion];
}

+(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
  httpBodyData:(NSData*)httpBodyData
      userInfo:(NSDictionary*)userInfo
    completion:(MEOApiManagerCompletion)completion
{
    MEOApiManager *apiManager = [[MEOApiManager alloc] init];
    [apiManager request:urlString
            headerField:headerField
             httpMethod:httpMethod
           httpBodyData:httpBodyData
               userInfo:userInfo
             completion:completion];
}

+(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
      httpBodyData:(NSData*)httpBodyData
      userInfo:(NSDictionary*)userInfo
      username:(NSString*)username
      password:(NSString*)password
    completion:(MEOApiManagerCompletion)completion
{
    MEOApiManager *apiManager = [[MEOApiManager alloc] init];
    [apiManager setUsername:username password:password];
    [apiManager request:urlString
            headerField:headerField
             httpMethod:httpMethod
           httpBodyData:httpBodyData
               userInfo:userInfo
             completion:completion];

}

+(void)download:(NSString*)urlString
       userInfo:(NSDictionary*)userInfo
       username:(NSString*)username
       password:(NSString*)password
     completion:(MEOApiManagerCompletion)completion
{
    MEOApiManager *apiManager = [[MEOApiManager alloc] init];
    [apiManager setUsername:username password:password];
    [apiManager request:urlString
            headerField:nil
             httpMethod:MEOApiManagerHttpMethodGet
               httpBody:nil
               userInfo:userInfo
             completion:completion];
}

+(void)download:(NSString*)urlString
       userInfo:(NSDictionary*)userInfo
     completion:(MEOApiManagerCompletion)completion
{
    [MEOApiManager download:urlString
                   userInfo:userInfo
                   username:nil
                   password:nil
                 completion:completion];
}
@end
