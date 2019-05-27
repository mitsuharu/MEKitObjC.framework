//
//  MEOLocationService.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2014/10/25.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

// http://uqtimes.blogspot.jp/2012/05/corelocationsample1-currentlocation.html
// 、<project-name>-Info.plistのUIBackgroundModesキーに「location」を追

/*
 
 edit plist as follows:
 
 <key>UIBackgroundModes</key>
 <array>
 <string>location</string>
 </array>
 
 <key>NSLocationAlwaysUsageDescription</key>
 <string>This app needs your location to give you accurate supports.</string>
 
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>The spirit of stack overflow is coders helping coders</string>
 
 
 */

@class MEOLocationService;

typedef void (^MEOLocationServiceCompletion) (MEOLocationService *locationService, CLAuthorizationStatus status, NSError *error);
typedef void (^MEOLocationServiceMonitored) (MEOLocationService *locationService, CLLocation *location);
typedef void (^MEOLocationServiceFailed) (MEOLocationService *locationService, NSError *error);

@protocol MEOLocationServiceDelegate <NSObject>

-(void)locationServiceMonitored:(MEOLocationService*)locationService location:(CLLocation*)location;
-(void)locationServiceFailed:(MEOLocationService*)locationService error:(NSError*)error;

@end

/**
 位置情報サービスを利用するための補助クラス
 
 * TargetsのCapabilities/Infoまたはxxx-Info.plistに項目を書き足す
 
 * 一定期間ごとにデータを取得する場合はUIBackgroundModesの設定が必要
 
 <key>UIBackgroundModes</key>
 <array>
 <string>location</string>
 </array>
 
 <key>NSLocationAlwaysUsageDescription</key>
 <string>This app needs your location to give you accurate supports.</string>
 
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>The spirit of stack overflow is coders helping coders</string>
 
 
 :param: void
 :returns: void
 */
@interface MEOLocationService : NSObject

@property (nonatomic) NSTimeInterval monitoringInterval;
@property (nonatomic) BOOL useBackground;
@property (nonatomic, retain) CLRegion *region;
@property (nonatomic, weak) id<MEOLocationServiceDelegate> delegate;
@property (nonatomic, copy) MEOLocationServiceMonitored completionMonitored;
@property (nonatomic, copy) MEOLocationServiceFailed completionFailed;
@property (nonatomic) BOOL permissionUsedLocationServiceAlways;
@property (nonatomic) NSInteger tag;

-(id)initWithDelegate:(id<MEOLocationServiceDelegate>)delegate;
-(CLAuthorizationStatus)authorizationStatus;

-(BOOL)startMonitoringLocation:(MEOLocationServiceCompletion)compeltion;
-(void)stopMonitoringLocation;

-(CLLocation*)currentLocation;

@end
