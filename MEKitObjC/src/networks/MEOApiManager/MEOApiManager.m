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
NSString* const MEOApiManagerHttpMethodHEAD = @"HEAD";
NSString* const MEOApiManagerLastModified = @"MEOApiManagerLastModified";

#pragma mark - MEOApiOption -

@implementation MEOApiOption

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setIgnoreCacheData:false];
        _username = nil;
        _password = nil;
        _userInfo = nil;
        _comparelastModified = false;
    }
    return self;
}

-(void)setIgnoreCacheData:(BOOL)ignoreCacheData
{
    // http://www.masayoshi1978.com/tech/?p=30
    // http://orih.io/2015/04/suspicious-header-definition-of-nsurlrequestcachepolicy/
    
    _ignoreCacheData = ignoreCacheData;
    if (ignoreCacheData) {
        _cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    }else{
        _cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
}


@end

#pragma mark - MEOApiManager -

@interface MEOApiManager () < NSURLSessionDelegate >

@property (nonatomic, retain) MEOApiOption *option;
-(void)showsNetworkActivityIndicator:(BOOL)visible;

@end

@implementation MEOApiManager

-(id)init
{
    if (self = [super init]) {
    }
    return self;
}

-(void)dealloc
{
    [self showsNetworkActivityIndicator:false];
}

#pragma mark 補助メソッド

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

- (NSDate*)lastModified:(NSURLResponse*)response
{
    NSDate *lastModified = nil;
    
    NSHTTPURLResponse *httpUrlResponse = (NSHTTPURLResponse*)response;
    NSDictionary *header = httpUrlResponse.allHeaderFields;
    NSString *key = @"Last-Modified";
    if ([header.allKeys containsObject:key]) {
        NSString *str = [header objectForKey:key];
        if (str && str.length > 0) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
            lastModified = [df dateFromString:str];
        }
    }
    
    return lastModified;
}

- (NSError*)errorWithErrorCode:(NSInteger)code
          localizedDescription:(NSString*)localizedDescription
{
    NSString *str = @"It is unknown error.";
    if (localizedDescription && localizedDescription.length > 0) {
        str = localizedDescription;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:str
                                                     forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                         code:code
                                     userInfo:dict];
    return error;
}

#pragma mark HTTPリクエスト

-(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
      httpBody:(NSString*)httpBody
        option:(MEOApiOption*)option
    completion:(MEOApiManagerCompletion)completion
{
    [self request:urlString
      headerField:headerField
       httpMethod:httpMethod
     httpBodyData:[httpBody dataUsingEncoding:NSUTF8StringEncoding]
           option:option
       completion:completion];
}

- (void)request:(NSString*)urlString
    headerField:(NSDictionary*)headerField
     httpMethod:(NSString*)httpMethod
   httpBodyData:(NSData*)httpBodyData
         option:(MEOApiOption*)option
     completion:(MEOApiManagerCompletion)completion
{
    self.option = option;
    
    if (urlString && urlString.length > 0) {
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                NSError *err = [self errorWithErrorCode:MEOApiManagerResultStatusRequestFailed
                                   localizedDescription:@"URL is invalid"];
                completion(MEOApiManagerResultStatusRequestFailed, nil, self.option.userInfo, -1, err);
            }
        });
        return;
    }
    
    if ([self reachabile] == false) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                NSError *err = [self errorWithErrorCode:MEOApiManagerResultStatusNetworkFailed
                                   localizedDescription:@"The Internet connection appears to be offline."];
                completion(MEOApiManagerResultStatusNetworkFailed, nil, self.option.userInfo, -1, err);
            }
        });
        return;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSessionConfiguration *config = nil;
    if (self.option.ignoreCacheData) {
        /*
         iOS8 - NSURLSessionConfigurationについてメモ - Qiita 
         <http://qiita.com/nomadmonad/items/c7f69dc9f8c7c1c77cb2>
         */
        config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    }else{
        config = [NSURLSessionConfiguration defaultSessionConfiguration];
    }

    if (self.option.ignoreCacheData) {
        config.requestCachePolicy = self.option.cachePolicy;
        config.URLCache = nil;
    }
    
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
    request.cachePolicy = self.option.cachePolicy;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:self
                                                     delegateQueue:nil];
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self showsNetworkActivityIndicator:false];
            
            if (self.option.ignoreCacheData) {
                NSURLCache *uc = [NSURLCache sharedURLCache];
                [uc removeCachedResponseForRequest:request];
                NSURLSessionDataTask *dtask = (NSURLSessionDataTask *)task;
                if (dtask) {
                    [uc removeCachedResponseForDataTask:dtask];                    
                }
            }
            
            NSDate *lastModified = [self lastModified:response];
            if (lastModified) {
                if (self.option == nil) {
                    self.option = [[MEOApiOption alloc] init];
                }
                if (self.option.userInfo == nil) {
                    self.option.userInfo = [[NSDictionary alloc] init];
                }
                NSMutableDictionary *dict = [self.option.userInfo mutableCopy];
                [dict setValue:lastModified forKey:MEOApiManagerLastModified];
                self.option.userInfo = [dict copy];
            }
            
            NSInteger statusCode = [self httpStatusCode:response];
            MEOApiManagerResultStatus resultStatus = MEOApiManagerResultStatusResponseFailed;
            if ( 0 <= (statusCode-200) && (statusCode-200) < 100) {
                resultStatus = MEOApiManagerResultStatusResponseSucsess;
            }
            
            if (error) {
                if ([error.domain isEqualToString:@"NSURLErrorDomain"]) {
                    if (error.code == kCFURLErrorNotConnectedToInternet) {
                        resultStatus = MEOApiManagerResultStatusNetworkFailed;
                    }
                }
            }
            
            if (completion) {
                completion(resultStatus, data, self.option.userInfo, statusCode, error);
            }
            
            [session invalidateAndCancel];
        });
    }];
    [task resume];
    [self showsNetworkActivityIndicator:true];
}

#pragma mark NSURLSessionDelegate

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
    } else if (self.option.username.length > 0 && self.option.password.length > 0){
        // Basic Auth.
        NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengeUseCredential;
        NSURLCredential *credential = [[NSURLCredential alloc] initWithUser:self.option.username
                                                                   password:self.option.password
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

#pragma mark 公開されるクラスメソッド

+ (NSDate*)lastModified:(NSDictionary*)userInfo
{
    NSDate *date = nil;
    if (userInfo
        && [userInfo isKindOfClass:[NSDictionary class]]
        && [userInfo.allKeys containsObject:MEOApiManagerLastModified]) {
        date = [userInfo objectForKey:MEOApiManagerLastModified];
    }
    return date;
}

+(NSDictionary*)parseJson:(NSData*)jsonData
{
    return [MEOApiManager parsedJsonDictionary:jsonData];
}

+ (id)parsedJsonObj:(NSData*)jsonData
{
    id json = nil;
    if (jsonData) {
        json = [NSJSONSerialization JSONObjectWithData:jsonData
                                               options:NSJSONReadingAllowFragments
                                                 error:nil];
    }
    return json;
}

+ (NSDictionary*)parsedJsonDictionary:(NSData*)jsonData
{
    id json = [MEOApiManager parsedJsonObj:jsonData];
    NSDictionary *jsonDict = nil;
    if (json && [json isKindOfClass:[NSDictionary class]]) {
        jsonDict = (NSDictionary*)json;
    }
    return jsonDict;
}

+ (NSArray*)parsedJsonArray:(NSData*)jsonData
{
    id json = [MEOApiManager parsedJsonObj:jsonData];
    NSArray *jsonArr = nil;
    if (json && [json isKindOfClass:[NSArray class]]) {
        jsonArr = (NSArray*)json;
    }
    return jsonArr;
}



+(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
      httpBody:(NSString*)httpBody
        option:(MEOApiOption*)option
    completion:(MEOApiManagerCompletion)completion
{
    MEOApiManager *apiManager = [[MEOApiManager alloc] init];
    [apiManager request:urlString
            headerField:headerField
             httpMethod:httpMethod
               httpBody:httpBody
               option:option
             completion:completion];
}

+(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
  httpBodyData:(NSData*)httpBodyData
        option:(MEOApiOption*)option
    completion:(MEOApiManagerCompletion)completion
{
    MEOApiManager *apiManager = [[MEOApiManager alloc] init];
    [apiManager request:urlString
            headerField:headerField
             httpMethod:httpMethod
           httpBodyData:httpBodyData
                 option:option
             completion:completion];
}

+(void)download:(NSString*)urlString
         option:(MEOApiOption*)option
     completion:(MEOApiManagerCompletion)completion
{
    MEOApiManager *apiManager = [[MEOApiManager alloc] init];
    [apiManager request:urlString
            headerField:nil
             httpMethod:MEOApiManagerHttpMethodGet
               httpBody:nil
               option:option
             completion:completion];
}

+ (void)requestLastModified:(NSString*)urlString
                     option:(MEOApiOption*)option
                 completion:(MEOApiManagerCompletion)completion
{
    MEOApiManager *apiManager = [[MEOApiManager alloc] init];
    [apiManager request:urlString
            headerField:nil
             httpMethod:MEOApiManagerHttpMethodHEAD
               httpBody:nil
                 option:option
             completion:completion];
}

#pragma mark 削除メソッドの仮対応


+(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
      httpBody:(NSString*)httpBody
      userInfo:(NSDictionary*)userInfo
    completion:(MEOApiManagerCompletion)completion
{
    MEOApiOption *option = [[MEOApiOption alloc] init];
    option.userInfo = userInfo;
    [MEOApiManager request:urlString
               headerField:headerField
                httpMethod:httpMethod
                  httpBody:httpBody
                    option:option
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
    MEOApiOption *option = [[MEOApiOption alloc] init];
    option.userInfo = userInfo;
    option.username = username;
    option.password = password;
    [MEOApiManager request:urlString
               headerField:headerField
                httpMethod:httpMethod
                  httpBody:httpBody
                    option:option
                completion:completion];
}

+(void)request:(NSString*)urlString
   headerField:(NSDictionary*)headerField
    httpMethod:(NSString*)httpMethod
  httpBodyData:(NSData*)httpBodyData
      userInfo:(NSDictionary*)userInfo
    completion:(MEOApiManagerCompletion)completion
{
    MEOApiOption *option = [[MEOApiOption alloc] init];
    option.userInfo = userInfo;
    [MEOApiManager request:urlString
               headerField:headerField
                httpMethod:httpMethod
                  httpBodyData:httpBodyData
                    option:option
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
    MEOApiOption *option = [[MEOApiOption alloc] init];
    option.userInfo = userInfo;
    option.username = username;
    option.password = password;
    [MEOApiManager request:urlString
               headerField:headerField
                httpMethod:httpMethod
              httpBodyData:httpBodyData
                    option:option
                completion:completion];
}

+(void)download:(NSString*)urlString
       userInfo:(NSDictionary*)userInfo
       username:(NSString*)username
       password:(NSString*)password
     completion:(MEOApiManagerCompletion)completion
{
    MEOApiOption *option = [[MEOApiOption alloc] init];
    option.userInfo = userInfo;
    option.username = username;
    option.password = password;
    [MEOApiManager download:urlString
                     option:option
                 completion:completion];
}

+(void)download:(NSString*)urlString
       userInfo:(NSDictionary*)userInfo
     completion:(MEOApiManagerCompletion)completion
{
    MEOApiOption *option = [[MEOApiOption alloc] init];
    option.userInfo = userInfo;
    [MEOApiManager download:urlString
                     option:option
                 completion:completion];
}

@end
