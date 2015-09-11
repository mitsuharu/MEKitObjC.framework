//
//  MEOLocationService.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2014/10/25.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOLocationService.h"

@interface MEOLocationService () <CLLocationManagerDelegate>
{
    NSInteger tag_;
    NSTimeInterval monitoringInterval_;
    BOOL useBackground_;
    
    CLRegion *region_;
    
    __weak id<MEOLocationServiceDelegate> delegate_;
    MEOLocationServiceMonitored completionMonitored_;
    MEOLocationServiceFailed completionFailed_;
    
    CLLocationManager *locationManager_;
    MEOLocationServiceCompletion completion_;
    
    BOOL permissionUsedLocationServiceAlways_;
    
    BOOL isMonitoring_;
    BOOL isRequestingLocation_;
    BOOL isRequestingRegion_;
    
    UIBackgroundTaskIdentifier bgTaskIdentifier_;
    NSTimer *monitoringTimer_;
    
    UIApplication *app_;
}

+(BOOL)enablelocationServices;
+(BOOL)enableRegion;
+(BOOL)isLocationBackgroundMode;
+(BOOL)isAuthorized:(CLAuthorizationStatus)status;

-(void)startLocation;

@end

@implementation MEOLocationService


@synthesize monitoringInterval = monitoringInterval_;
@synthesize useBackground = useBackground_;
@synthesize region = region_;
@synthesize delegate = delegate_;
@synthesize completionFailed = completionFailed_;
@synthesize completionMonitored = completionMonitored_;
@synthesize permissionUsedLocationServiceAlways = permissionUsedLocationServiceAlways_;
@synthesize tag = tag_;

// MARK: for lifecycle

-(id)init
{
    if (self = [super init]) {
        tag_ = 0;
        useBackground_ = true;
        bgTaskIdentifier_ = UIBackgroundTaskInvalid;
        permissionUsedLocationServiceAlways_ = true;
        isMonitoring_ = false;
        isRequestingLocation_ = false;
        isRequestingRegion_ = false;
        locationManager_ = [[CLLocationManager alloc] init];
        locationManager_.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager_.distanceFilter = kCLDistanceFilterNone;
        locationManager_.pausesLocationUpdatesAutomatically = false;
        locationManager_.delegate = self;
        
        app_ = [UIApplication sharedApplication];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(willEnterForeground:)
                   name:UIApplicationWillEnterForegroundNotification
                 object:nil];
        [nc addObserver:self
               selector:@selector(willResignActive:)
                   name:UIApplicationWillResignActiveNotification
                 object:nil];
        
    }
    return self;
}

-(id)initWithDelegate:(id<MEOLocationServiceDelegate>)delegate
{
    if ( self = [self init]){
        delegate_ = delegate;
    }
    return self;
}

-(void)dealloc
{
    delegate_ = nil;
    
    if (monitoringTimer_ != nil){
        monitoringTimer_ = nil;
    }
    
    locationManager_.delegate = nil;
    locationManager_ = nil;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}


-(CLAuthorizationStatus)authorizationStatus
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    return status;
}

-(CLLocation*)currentLocation
{
    return locationManager_.location;
}

// MARK: - for Class Methods

+(BOOL)enablelocationServices
{
    return [CLLocationManager locationServicesEnabled];
}

+(BOOL)enableRegion
{
    return [CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]];
}

+(BOOL)isLocationBackgroundMode
{
    NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];
    BOOL mode = NO;
    if ([dict.allKeys containsObject:@"UIBackgroundModes"]) {
        NSArray *arr = [dict objectForKey:@"UIBackgroundModes"];
        for (NSString *str in arr) {
            if ([str isEqualToString:@"location"]) {
                mode = true;
                break;
            }
        }
    }
    return mode;
}

+(BOOL)isAuthorized:(CLAuthorizationStatus)status
{
    BOOL auth = false;
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1){
        auth = (status == kCLAuthorizationStatusAuthorizedAlways
                || status == kCLAuthorizationStatusAuthorizedWhenInUse);
    }
    else{
        auth = (status == kCLAuthorizationStatusAuthorized);
    }
//    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1){
//        auth = (status == kCLAuthorizationStatusAuthorized
//                || status == kCLAuthorizationStatusAuthorizedAlways);
//    }
//    else{
//        auth = (status == kCLAuthorizationStatusAuthorizedAlways
//                || status == kCLAuthorizationStatusAuthorizedAlways);
//    }
    return auth;
}

// MARK: - for Background

-(void)startBackgroundTask
{
    [self stopBackgroundTask];
    bgTaskIdentifier_ = [app_ beginBackgroundTaskWithExpirationHandler:^{
        [self stopBackgroundTask];
    }];
    
}

-(void)stopBackgroundTask
{
    if (bgTaskIdentifier_ != UIBackgroundTaskInvalid){
        [app_ endBackgroundTask:bgTaskIdentifier_];
        bgTaskIdentifier_ = UIBackgroundTaskInvalid;
    }
}

-(void)willEnterForeground:(NSNotification*)notification
{
    if ( useBackground_){
        [self stopBackgroundTask];
    }
}

-(void)willResignActive:(NSNotification*)notification
{
    if (useBackground_ && [MEOLocationService enablelocationServices]) {
        [self startBackgroundTask];
    }
}

// MARK: for Locations

-(void)startLocation
{
    monitoringTimer_ = [NSTimer scheduledTimerWithTimeInterval:monitoringInterval_
                                                        target:self
                                                      selector:@selector(didMonitorLocationData:)
                                                      userInfo:nil
                                                       repeats:true];
    isRequestingLocation_ = true;
    isMonitoring_ = true;
    
    if ([MEOLocationService isLocationBackgroundMode]) {
        [locationManager_ startUpdatingLocation];
        [self didMonitorLocationData:monitoringTimer_];
    }else{
        if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
            [locationManager_ startMonitoringSignificantLocationChanges];
        }else{
            [locationManager_ startUpdatingLocation];
        }
    }
}

-(BOOL)startMonitoringLocation:(MEOLocationServiceCompletion)compeltion
{
    BOOL result = false;
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if ([CLLocationManager locationServicesEnabled] == false) {
        if (compeltion) {
            NSString *key = @"LocationServiceDisabled";
            NSDictionary *dict = [NSDictionary dictionaryWithObject:key forKey:key];
            NSError *error = [NSError errorWithDomain:key code:-1 userInfo:dict];
            compeltion(self, status, error);
        }
        return result;
    }
    
    if (isMonitoring_) {
        NSLog(@"return isMonitoring_");
        return result;
    }
    
    if (status == kCLAuthorizationStatusNotDetermined) {
        if ([locationManager_ respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            isRequestingLocation_ = true;
            completion_ = compeltion;
            if (permissionUsedLocationServiceAlways_) {
                [locationManager_ requestAlwaysAuthorization];
            }else{
                [locationManager_ requestWhenInUseAuthorization];
            }
        }else{
            isRequestingLocation_ = true;
            [self startLocation];
            if (compeltion) {
                compeltion(self, status, nil);
            }
        }
    }else if ([MEOLocationService isAuthorized:status]){
        [self startLocation];
        if (compeltion) {
            compeltion(self, status, nil);
        }
    }else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted){
        if (compeltion) {
            NSString *key = @"LocationServiceDenied";
            NSDictionary *dict = [NSDictionary dictionaryWithObject:key forKey:key];
            NSError *error = [NSError errorWithDomain:key code:-1 userInfo:dict];
            compeltion(self, status, error);
        }
        return result;
    }
    
    return result;
}


-(void)stopMonitoringLocation
{
    if (monitoringTimer_) {
        [monitoringTimer_ invalidate];
        monitoringTimer_ = nil;
    }
    
    if (locationManager_) {
        [self stopBackgroundTask];
        isRequestingLocation_ = false;
        isMonitoring_ = false;

        if ([MEOLocationService isLocationBackgroundMode]) {
            [locationManager_ stopUpdatingLocation];
        }else{
            if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
                [locationManager_ stopMonitoringSignificantLocationChanges];
            }else{
                [locationManager_ stopUpdatingLocation];
            }
        }
    }
}

// MARK: for Region

-(void)startRegion:(CLRegion*)region
{
    monitoringTimer_ = [NSTimer scheduledTimerWithTimeInterval:monitoringInterval_
                                                        target:self
                                                      selector:@selector(didMonitorLocationData:)
                                                      userInfo:nil
                                                       repeats:true];
    isRequestingRegion_ = true;
    isMonitoring_ = true;
    region_ = region;
    
    [locationManager_ startMonitoringForRegion:region_];
}

-(BOOL)startMonitoringRegion:(CLRegion*)region completion:(MEOLocationServiceCompletion)compeltion
{
    BOOL result = false;
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if ([MEOLocationService enableRegion] == false) {
        if (compeltion) {
            NSString *key = @"LocationServiceDisabled";
            NSDictionary *dict = [NSDictionary dictionaryWithObject:key forKey:key];
            NSError *error = [NSError errorWithDomain:key code:-1 userInfo:dict];
            compeltion(self, status, error);
        }
        return result;
    }
    
    if (isMonitoring_) {
        return result;
    }
    
    if (status == kCLAuthorizationStatusNotDetermined) {
        if ([locationManager_ respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            isRequestingRegion_ = true;
            completion_ = compeltion;
            region_ = region;
            if (permissionUsedLocationServiceAlways_) {
                [locationManager_ requestAlwaysAuthorization];
            }else{
                [locationManager_ requestWhenInUseAuthorization];
            }
        }else{
            isRequestingLocation_ = true;
            [self startLocation];
            if (compeltion) {
                compeltion(self, status, nil);
            }
        }
    }else if ([MEOLocationService isAuthorized:status]){
        [self startRegion:region];
        if (compeltion) {
            compeltion(self, status, nil);
        }
    }else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted){
        if (compeltion) {
            NSString *key = @"LocationServiceDenied";
            NSDictionary *dict = [NSDictionary dictionaryWithObject:key forKey:key];
            NSError *error = [NSError errorWithDomain:key code:-1 userInfo:dict];
            compeltion(self, status, error);
        }
        return result;
    }
    
    return result;
}


-(void)stopMonitoringRegion:(CLRegion*)region
{
    if (monitoringTimer_) {
        [monitoringTimer_ invalidate];
        monitoringTimer_ = nil;
    }
    
    if (locationManager_ && region) {
        [self stopBackgroundTask];
        isRequestingRegion_ = false;
        isMonitoring_ = false;
        [locationManager_ stopMonitoringForRegion:region];
        region_ = nil;
    }
}

-(void)didMonitorLocationData:(NSTimer*)timer
{
    if (locationManager_.location == nil) {
        return;
    }
    
    CLLocation *location = locationManager_.location;
    if (completionMonitored_) {
        completionMonitored_(self, location);
    }
    if (delegate_ && [delegate_ respondsToSelector:@selector(locationServiceMonitored:location:)]) {
        [delegate_ locationServiceMonitored:self location:location];
    }
    
}

// MARK: - for CLLocationManagerDelagate (Authorization)

-(void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ([MEOLocationService isAuthorized:status]) {
        if (isRequestingLocation_) {
            [self startLocation];
            if (completion_) {
                completion_(self, status, nil);
            }
        }else if (isRequestingRegion_ && region_){
            [self startRegion:region_];
            if (completion_) {
                completion_(self, status, nil);
            }
        }
    }else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        if (completion_) {
            NSString *key = @"LocationServiceDenied";
            NSDictionary *dict = [NSDictionary dictionaryWithObject:key forKey:key];
            NSError *error = [NSError errorWithDomain:key code:-1 userInfo:dict];
            completion_(self, status, error);
        }
    }
    isRequestingRegion_ = false;
    isRequestingLocation_ = false;
}

// MARK: for CLLocationManagerDelagate (Location)

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (locations && locations.count > 0) {
        CLLocation *loc = locations.firstObject;
        NSDate *dste = loc.timestamp;
        NSTimeInterval howRecent = [dste timeIntervalSinceNow];
        if (15.0 < fabs(howRecent)) {
            return;
        }
    }


    if ([MEOLocationService isLocationBackgroundMode]) {
        return;
    }
    
    if (monitoringTimer_ || completionMonitored_ || delegate_) {
        [self didMonitorLocationData:monitoringTimer_];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (completionFailed_) {
        completionFailed_(self, error);
    }
    if (delegate_ && [delegate_ respondsToSelector:@selector(locationServiceFailed:error:)]) {
        [delegate_ locationServiceFailed:self error:error];
    }
    
    if (error.code == kCLErrorLocationUnknown) {
    }else if (error.code == kCLErrorHeadingFailure){
    }else if (error.code == kCLErrorDenied) {
        [self stopMonitoringLocation];
        if (region_) {
            [self stopMonitoringRegion:region_];
        }
    }
}

@end


























