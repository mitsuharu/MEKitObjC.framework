//
//  MEOSensor.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2014/12/11.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@class MEOSensor;

typedef void (^MEOSensorComletion)(MEOSensor *sensor, BOOL completion);

@protocol MEOSensorDelegate <NSObject>

@optional

-(void)measuredAccelerometer:(MEOSensor*)sensor completion:(BOOL)completion;

@end


@interface MEOSensor : NSObject

@property (weak) id<MEOSensorDelegate> delegate;

-(double)force;
-(CMAcceleration)acceleration;


-(void)startAccelerometer:(MEOSensorComletion)comletion;
-(void)stopAccelerometer;

-(UIDeviceOrientation)physicalOrientation;
-(UIDeviceOrientation)systematicOrientation;
-(BOOL)isScreenLock;

@end
