//
//  MEOAuthorization.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2014/10/30.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOAuthorization.h"
#import <MEKitObjC/MEKitObjC.h>
#import <Social/Social.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface MEOAuthorization ()
{
    NSString *facebookAppId_;
}

+(MEOAuthorization*)sharedAuthorization;
-(MEOAuthorizationErrorCode)errorCode:(NSError*)error;

-(void)authorizeWithFacebook:(NSString*)facebookAppId
                    audience:(NSString*)audience
                 permissions:(NSArray*)permissions
                  completion:(MEOAuthorizationCompletion)completion;


-(void)requestFacebookGraphPath:(NSString*)graphPath
                         fields:(NSArray*)fields
                     completion:(MEOAuthorizationWithResponse)completion;

-(void)requestFacebookGraphMe:(MEOAuthorizationWithResponse)completion;


@end

@implementation MEOAuthorization


#pragma mark - lifecycle

-(id)init
{
    if (self = [super init]) {
        self.accountStore = [[ACAccountStore alloc] init];
        self.facebookAccount = nil;
        facebookAppId_ = nil;
    }
    return self;
}

+(MEOAuthorization*)sharedAuthorization
{
    static MEOAuthorization* singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
    });
    return singleton;
}

-(MEOAuthorizationErrorCode)errorCode:(NSError*)error
{
    MEOAuthorizationErrorCode errorCode = MEOAuthorizationErrorCodeUnknown;
    if (error){
        errorCode = MEOAuthorizationErrorCodeUnknown;
        if ([error.domain isEqualToString:@"NSURLErrorDomain"]) {
            if (error.code == kCFURLErrorNotConnectedToInternet) {
                errorCode = MEOAuthorizationErrorCodeNetworkFailed;
            }
        }else if ([error.domain isEqualToString:@"com.apple.accounts"]){
            if(error.code == ACErrorAccountNotFound){
                errorCode = MEOAuthorizationErrorCodeAccountNotFound;
            } else {
                errorCode = MEOAuthorizationErrorCodePermissionDenied;
            }
        }
    }
    return errorCode;
}


#pragma mark - 画像ライブラリ

+(void)authorizePhotoLibray:(void(^)(MEOAuthorizationStatus status))completion
{
    id object = NSClassFromString(@"PHPhotoLibrary");
    if (object) {
        
        MEOAuthorizationStatus (^convertStatus)(PHAuthorizationStatus status0) = ^(PHAuthorizationStatus status0) {
            MEOAuthorizationStatus result0 = MEOAuthorizationStatusNotDetermined;
            if (status0 == PHAuthorizationStatusNotDetermined){
                result0 = MEOAuthorizationStatusNotDetermined;
            } else if (status0 == PHAuthorizationStatusRestricted){
                result0 = MEOAuthorizationStatusRestricted;
            } else if (status0 == PHAuthorizationStatusDenied){
                result0 = MEOAuthorizationStatusDenied;
            } else if (status0 == PHAuthorizationStatusAuthorized){
                result0 = MEOAuthorizationStatusAuthorized;
            }
            return result0;
        };
        
        PHAuthorizationStatus status0 = [PHPhotoLibrary authorizationStatus];
        if (status0 == PHAuthorizationStatusNotDetermined){
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(convertStatus(status1));
                    }
                });
            }];
        }else{
            if (completion) {
                completion(convertStatus(status0));
            }
        }
        
    }else{
        MEOAuthorizationStatus result = MEOAuthorizationStatusNotDetermined;
        ALAuthorizationStatus status0 = [ALAssetsLibrary authorizationStatus];
        if (status0 == ALAuthorizationStatusNotDetermined){
            result = MEOAuthorizationStatusNotDetermined;
        } else if (status0 == ALAuthorizationStatusRestricted){
            result = MEOAuthorizationStatusRestricted;
        } else if (status0 == ALAuthorizationStatusDenied){
            result = MEOAuthorizationStatusDenied;
        } else if (status0 == ALAuthorizationStatusAuthorized){
            result = MEOAuthorizationStatusAuthorized;
        }
        
        if (completion) {
            completion(result);
        }
    }
    
}

+(void)authorizeCameraDevice:(void(^)(BOOL granted))completion
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                 completionHandler:^(BOOL granted)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (completion) {
                     completion(granted);
                 }
             });
         }];
    }else if (status == AVAuthorizationStatusRestricted
              || status == AVAuthorizationStatusDenied){
        if (completion) {
            completion(false);
        }
    }else if (status == AVAuthorizationStatusAuthorized) {
        if (completion) {
            completion(true);
        }
    }
}

+(BOOL)openSettingApp
{
    BOOL result = false;
    if (&UIApplicationOpenSettingsURLString != Nil) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        UIApplication *app = [UIApplication sharedApplication];
        result = [app canOpenURL:url];
        if (result) {
            [app openURL:url];
        }
    }
    return result;
}

+(BOOL)isCameraAvailable
{
    BOOL result = false;
#if(TARGET_IPHONE_SIMULATOR)
#else
    result = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
#endif
    return result;
}

#pragma mark - facebook


-(void)authorizeWithFacebook:(NSString*)facebookAppId
                    audience:(NSString*)audience
                 permissions:(NSArray*)permissions
                  completion:(MEOAuthorizationCompletion)completion
{
    if (facebookAppId == nil || facebookAppId.length == 0) {
        if (completion) {
            completion(nil, nil, MEOAuthorizationErrorCodePermissionDenied);
        }
        return;
    }
    
    NSString *requestedAudience = ACFacebookAudienceOnlyMe;
    if (audience) {
        requestedAudience = audience;
    }
    
    NSArray *requestedPermissions = @[@"email"];
    if (permissions) {
        requestedPermissions = permissions;
    }
    
    self.accountStore = [[ACAccountStore alloc] init];
    ACAccountType *facebookTypeAccount = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *options = @{ACFacebookAppIdKey:facebookAppId,
                              ACFacebookAudienceKey:requestedAudience,
                              ACFacebookPermissionsKey:requestedPermissions};
    
    [self.accountStore requestAccessToAccountsWithType:facebookTypeAccount
                                               options:options
                                            completion:^(BOOL granted, NSError *error)
    {
        MEOAuthorizationErrorCode errorCode = MEOAuthorizationErrorCodeNone;
        if (granted){
            NSArray *accounts = [self.accountStore accountsWithAccountType:facebookTypeAccount];
            self.facebookAccount = [accounts lastObject];
        }else{
            errorCode = [self errorCode:error];
        }
                
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(self.facebookAccount, error, errorCode);
            }
        });
    }];
}

-(void)requestFacebookGraphMe:(MEOAuthorizationWithResponse)completion
{
    [self requestFacebookGraphPath:@"me"
                            fields:nil
                        completion:completion];
}

-(void)requestFacebookGraphPath:(NSString*)graphPath
                         fields:(NSArray*)fields
                     completion:(MEOAuthorizationWithResponse)completion
{
    if (self.facebookAccount == nil) {
        if (completion) {
            NSError *error = [NSError errorWithErrorCode:0
                                    localizedDescription:@"I do not have facebook account (ACAcount instance)."];
            completion(nil, error, MEOAuthorizationErrorCodePermissionDenied);
        }
        return;
    }
    
    NSString *domain = @"https://graph.facebook.com/";
    NSString *path = @"me";
    if (graphPath) {
        NSString *tempGraphPath = graphPath;
        if ([graphPath hasPrefix:@"/"]) {
            tempGraphPath = [graphPath substringFromIndex:1];
        }
        path = tempGraphPath;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@", domain, path];
    
    NSMutableDictionary *parameterDict = nil;
    if (fields && fields.count > 0) {
        parameterDict = [[NSMutableDictionary alloc] initWithCapacity:1];
        [parameterDict setObject:[fields componentsJoinedByString:@","]
                 forKey:@"fields"];
    }
    
    NSLog(@"urlString %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                            requestMethod:SLRequestMethodGET
                                                      URL:url
                                               parameters:parameterDict];
    request.account = self.facebookAccount;
    
    [request performRequestWithHandler:^(NSData *data,
                                         NSHTTPURLResponse *response,
                                         NSError *error)
    {
        NSDictionary *responseDict = nil;
        if (data && !error) {
            responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                           options:NSJSONReadingAllowFragments
                                                             error:nil];
        }

        [self dispatchSync:^{
            if(responseDict && [responseDict objectForKey:@"error"]){
                [self attemptRenewCredentials:self.facebookAccount
                                   completion:^(BOOL renewed, ACAccountCredentialRenewResult renewResult, NSError *error)
                {
                    if (renewed) {
                        [self requestFacebookGraphPath:graphPath
                                                fields:fields
                                            completion:completion];
                    }
                }];
            }else if (completion) {
                MEOAuthorizationErrorCode errorCode = [self errorCode:error];
                completion(responseDict, error, errorCode);
            }
        }];
    }];
}

-(void)attemptRenewCredentials:(ACAccount*)account
                    completion:(MEOAuthorizationRenewCredentials)completion
{
    [self.accountStore renewCredentialsForAccount:(ACAccount *)self.facebookAccount
                                       completion:^(ACAccountCredentialRenewResult renewResult, NSError *error)
    {
        BOOL success = false;
        if (error != nil && renewResult == ACAccountCredentialRenewResultRenewed ) {
            success = true;
        }
        [self dispatchSync:^{
            if (completion) {
                completion(success, renewResult, error);
            }
        }];
    }];
}


+(void)authorizeWithFacebook:(NSString*)facebookAppId
                  completion:(MEOAuthorizationCompletion)completion
{
    [MEOAuthorization authorizeWithFacebook:facebookAppId
                                   audience:ACFacebookAudienceOnlyMe
                                permissions:@[@"email"]
                                 completion:completion];
}


+(void)authorizeWithFacebook:(NSString*)facebookAppId
                    audience:(NSString*)audience
                 permissions:(NSArray*)permissions
                  completion:(MEOAuthorizationCompletion)completion
{
    MEOAuthorization *auth = [MEOAuthorization sharedAuthorization];
    [auth authorizeWithFacebook:facebookAppId
                       audience:audience
                    permissions:permissions
                     completion:completion];
}

;

+(void)requestFacebookGraphMe:(MEOAuthorizationWithResponse)completion
{
    MEOAuthorization *auth = [MEOAuthorization sharedAuthorization];
    [auth requestFacebookGraphMe:completion];
}

+(void)requestFacebookGraphPath:(NSString*)graphPath
                         fields:(NSArray*)fields
                     completion:(MEOAuthorizationWithResponse)completion
{
    MEOAuthorization *auth = [MEOAuthorization sharedAuthorization];
    [auth requestFacebookGraphPath:graphPath
                            fields:fields
                        completion:completion];
}



#pragma mark - notifications

// http://qiita.com/peromasamune/items/90970e9f9d5c34d21cfd
// https://ios-practice.readthedocs.org/en/latest/docs/notification/

// http://stackoverflow.com/questions/25570015/ios8-check-permission-of-remotenotificationtype

+(BOOL)isRegisteredForRemoteNotifications
{
    BOOL isgranted = false;
    UIApplication *app = [UIApplication sharedApplication];
    if ([app respondsToSelector:@selector(isRegisteredForRemoteNotifications)]){
        isgranted =  [app isRegisteredForRemoteNotifications];
        if (isgranted) {
            UIUserNotificationSettings *settings = [app currentUserNotificationSettings];
            isgranted = (settings.types != UIUserNotificationTypeNone);
        }
    }else{
        UIRemoteNotificationType types = [app enabledRemoteNotificationTypes];
        if (types & UIRemoteNotificationTypeAlert){
            isgranted = true;
        }
    }
    return isgranted;
}

+(void)registerUserNotifications:(BOOL)containsRemoteNotifications
{
    UIApplication *app = [UIApplication sharedApplication];
    if ([app respondsToSelector:@selector(registerUserNotificationSettings:)]){
        UIUserNotificationType type = (UIUserNotificationTypeBadge|
                                       UIUserNotificationTypeSound|
                                       UIUserNotificationTypeAlert);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        
        [app registerUserNotificationSettings:settings];
        
        
    }else if (containsRemoteNotifications){
        // iOS7以下向け
        UIRemoteNotificationType type = (UIRemoteNotificationTypeBadge|
                                         UIRemoteNotificationTypeSound|
                                         UIRemoteNotificationTypeAlert);
        [app registerForRemoteNotificationTypes:type];
    }
}

+(void)registerRemoteNotifications
{
    UIApplication *app = [UIApplication sharedApplication];
    if ([app respondsToSelector:@selector(registerForRemoteNotifications)]){
        [app registerForRemoteNotifications];
    }
}

+(NSString*)stringWithDeviceToken:(NSData*)deviceToken
{
    NSCharacterSet *chrSet = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    NSString *str = [[deviceToken description] stringByTrimmingCharactersInSet:chrSet];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return str;
}


@end
