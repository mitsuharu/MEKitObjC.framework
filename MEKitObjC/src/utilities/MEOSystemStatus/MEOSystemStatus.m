//
//  MEOSystemStatus.m
//  MEKitObjC
//
//  Created by Emoto Mitsuharu on 11/11/02.
//  Copyright (c) 2011年 Mitsuharu Emoto. All rights reserved.
//

// http://d.hatena.ne.jp/shu223/20110427/1303921157
// http://d.hatena.ne.jp/It_lives_vainly/20090325/1237952703

#import "MEOSystemStatus.h"
#import "MyReachability.h"

#import <UIKit/UIKit.h>
#include <sys/types.h>
#include <sys/sysctl.h>

#define THE_TOUGH_HOST @"www.google.com"


const NSString* NotificationNetworkBecomeSuccess = @"NotificationNetworkBecomeSuccess";
const NSString*  NotificationNetworkBecomeFailure = @"NotificationNetworkBecomeFailure";

@interface MEOSystemStatus ()
{
    MyReachability* reach_;
    __weak id<MEOSystemStatusDelegate> delegate_;
    ReachableStatusBlock reachableStatus_;
}

-(void)reachabilityChanged:(NSNotification* )notification;

@end


@implementation MEOSystemStatus

@synthesize delegate = delegate_;

+(id)shareInstance
{
    static id singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[MEOSystemStatus alloc] init];
    });
    return singleton;
}

-(id)init
{
    if (self = [super init]) {
        reach_ = nil;
        delegate_ = nil;
    }
    return self;
}

-(id)initWithDelegate:(id<MEOSystemStatusDelegate>)delegate
{
    if (self = [super init]) {
        reach_ = nil;
        delegate_ = delegate;
    }
    return self;
}

-(void)dealloc
{
    [self stopReachableNotification];
}


-(void)startReachableNotification
{
    [self startReachableNotification:nil completion:nil];
}

-(void)startReachableNotification:(NSString*)targetUrl
                       completion:(ReachableStatusBlock)reachableStatus
{
    if (targetUrl && targetUrl.length > 0) {
        reach_ = [MyReachability reachabilityWithHostName:targetUrl];
    }else{
        reach_ = [MyReachability reachabilityForInternetConnection];
    }
    [reach_ startNotifier];
    reachableStatus_ = reachableStatus;
    
    NetworkStatus status = [reach_ currentReachabilityStatus];
    if (reachableStatus_) {
        reachableStatus_((status==NotReachable)?NO:YES);
    }    
    if (delegate_ && [delegate_ respondsToSelector:@selector(systemStatus:changeReachableStatus:)]) {
        [delegate_ systemStatus:self
          changeReachableStatus:(status==NotReachable)?NO:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reachabilityChanged:)
												 name:kReachabilityChangedNotification
											   object:nil];
}

-(void)stopReachableNotification
{
    if (reach_) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:kReachabilityChangedNotification
                                                      object:nil];
        
        [reach_ stopNotifier];
        reach_ = nil;
        reachableStatus_ = nil;
    }
}

-(void)reachabilityChanged:(NSNotification* )notification
{
    MyReachability* curReach = [notification object];
    NetworkStatus status = [curReach currentReachabilityStatus];
    if (reachableStatus_) {
        reachableStatus_((status==NotReachable)?NO:YES);
    }
    
    if (delegate_ && [delegate_ respondsToSelector:@selector(systemStatus:changeReachableStatus:)]) {
        [delegate_ systemStatus:self
          changeReachableStatus:(status==NotReachable)?NO:YES];
    }
    
//    if (delegate_ && [delegate_ respondsToSelector:@selector(systemStatus:changeReachableStatus:)]) {
//        [delegate_ systemStatus:self
//          changeReachableStatus:(status==NotReachable)?NO:YES];
//    }
}

#pragma mark - for display size

+(BOOL)displayIs3inch
{
    BOOL inch = NO;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if(screenSize.width == 320.0 && screenSize.height == 480.0){
        inch = YES;
    }
    return inch;
}


+(BOOL)displayIs4inch
{
    BOOL inch = NO;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if(screenSize.width == 320.0 && screenSize.height == 568.0){
        inch = YES;
    }
    return inch;
}



#pragma mark - for networks

+(BOOL)reachabile
{
    return ([MEOSystemStatus reachabileInternet] || [MEOSystemStatus reachabileWifi]);
//    return [SystemStatus reachabileHost:THE_TOUGH_HOST];
}

+(BOOL)reachabileHost:(NSString *)url
{
    MyReachability* reach = [MyReachability reachabilityWithHostName:url];
    NetworkStatus status = [reach currentReachabilityStatus];
    reach = nil;
    return (status==NotReachable)?NO:YES;
}

+(BOOL)reachabileInternet
{
    MyReachability* reach = [MyReachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    reach = nil;
    return (status==NotReachable)?NO:YES;
}

+(BOOL)reachabileWifi
{
    MyReachability* reach = [MyReachability reachabilityForLocalWiFi];
    NetworkStatus status = [reach currentReachabilityStatus];
    reach = nil;
    return (status==NotReachable)?NO:YES;
}

+(NSInteger)httpStatusCode:(NSString *)url error:(NSError**)error
{
    // 2xx: successful
    // 4xx: request error
    // 5xx: server error
    
    NSInteger code = -1;

    if ([self reachabile] == NO)
    {
        if (error) {
            NSMutableDictionary* errDetails = [NSMutableDictionary dictionary];
            [errDetails setValue:@"Your network is disabled." forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"network error" code:200 userInfo:errDetails];
        }
        return code;
    }
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSHTTPURLResponse *response = nil;
    NSError *err = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest
                                                 returningResponse:&response
                                                             error:&err];
    code = [response statusCode];
    if (error) {
        *error = err;
    }
    responseData = nil;
    
    return code;
}

#pragma mark - version

+(NSInteger)versionMajor{
    NSArray *aOsVersions = [[[UIDevice currentDevice]systemVersion] componentsSeparatedByString:@"."];
    return [[aOsVersions objectAtIndex:0] intValue];
}

+(NSInteger)versionMinor{
    NSArray *aOsVersions = [[[UIDevice currentDevice]systemVersion] componentsSeparatedByString:@"."];
    return [[aOsVersions objectAtIndex:1] intValue];
}

#pragma mark -

+(NSString *)platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    
    /*
     Possible values:
     "i386" = iPhone Simulator
     
     "iPhone1,1" = iPhone 1G
     "iPhone1,2" = iPhone 3G
     "iPhone2,1" = iPhone 3GS
     "iPhone3,1" = iPhone 4
     "iPhone3,3" = iPhone 4 (CDMA)
     "iPhone4,1" = iPhone 4S
     "iPhone5,2" = iPhone 5
     
     "iPod1,1"   = iPod touch 1G
     "iPod2,1"   = iPod touch 2G
     "iPod3,1"   = iPod touch 3G
     "iPod4,1"   = iPod touch 4G
     
     "iPad1,1"   = iPod
     "iPad2,1"   = iPod 2 (WiFi)
     "iPad2,2"   = iPod 2 (GSM)
     "iPad2,3"   = iPod 2 (CDMA)
     
     "AppleTV2,1"   = AppleTV (2G)
     */
    
    NSString *platform = [NSString stringWithCString: machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

+(BOOL)isIphone
{
    NSString *platform_ = [MEOSystemStatus platform];
    return [platform_ hasPrefix:@"iPhone"];    
}

+(BOOL)isIphone3GS 
{
    NSString *platform_ = [MEOSystemStatus platform];
    return [platform_ hasPrefix:@"iPhone2,"];
}

+(BOOL)isIphone4 
{
    NSString *platform_ = [MEOSystemStatus platform];
    return [platform_ hasPrefix:@"iPhone3,"];
}

+(BOOL)isIphone4S
{
    NSString *platform_ = [MEOSystemStatus platform];
    return [platform_ hasPrefix:@"iPhone4,"];
}

+(BOOL)isIpodTouch
{
    NSString *platform_ = [MEOSystemStatus platform];
    return [platform_ hasPrefix:@"iPod"];
}

+(BOOL)isIpodTouch4th
{
    NSString *platform_ = [MEOSystemStatus platform];
    return [platform_ hasPrefix:@"iPod4"];    
}

+(BOOL)isIpad
{
    NSString *platform_ = [MEOSystemStatus platform];
    return [platform_ hasPrefix:@"iPad"];  
}

+(BOOL)isIpad1
{
    NSString *platform_ = [MEOSystemStatus platform];
    return [platform_ hasPrefix:@"iPad1"];  
}

+(BOOL)isIpad2
{
    NSString *platform_ = [MEOSystemStatus platform];
    return [platform_ hasPrefix:@"iPad2"];  
}

@end
