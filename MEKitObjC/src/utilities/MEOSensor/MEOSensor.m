//
//  MEOSensor.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2014/12/11.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOSensor.h"

#define kStepThreshold 1.2
#define kFrequency 60.0
#define kFilteringFactor 0.1


// MARK: - MEOForceData

typedef struct {
    double current;
    double previous;
    NSInteger changed;
}MEOForceData;

MEOForceData MEOForceDataMake(double current, double previous, NSInteger changed){
    MEOForceData f;
    f.previous = current;
    f.current = previous;
    f.changed = changed;
    return f;
}

double MEOForceDataMin(MEOForceData f){
    return MIN(f.current, f.previous);
}

double MEOForceDataMax(MEOForceData f){
    return MAX(f.current, f.previous);
}

void MEOForceDataUpdate(MEOForceData f){
    f.previous = f.current;
}

// MARK: - CMAcceleration Helper

CMAcceleration CMAccelerationMake(double x, double y, double z){
    CMAcceleration s;
    s.x = x;
    s.y = y;
    s.x = z;
    return s;
}

BOOL CMAccelerationIsEqual(CMAcceleration s1, CMAcceleration s2){
    return ((s1.x==s2.x)&&(s1.y==s2.y)&&(s1.z==s2.z));
}

CMAcceleration CMAccelerationLowpassFilter(CMAcceleration current, CMAcceleration previous, double factor){
    CMAcceleration s;
    s.x = current.x * factor + previous.x *(1-factor);
    s.y = current.y * factor + previous.y *(1-factor);
    s.z = current.z * factor + previous.z *(1-factor);
    return s;
}

double CMAccelerationLpf(CMAcceleration s){
    return sqrt((s.x*s.x)+(s.y*s.y)+(s.z*s.z));
}

// MARK: - MEOSensorData

typedef struct {
    CMAcceleration acceleration;
    NSTimeInterval timestamp;
}MEOSensorData;

void MEOSensorDataInit(MEOSensorData s){
    s.timestamp = 0.0;
    s.acceleration = CMAccelerationMake(0, 0, 0);
}

// MARK: - MEOSensor

@interface MEOSensor ()
{
    MEOSensorData sensorData_;
    MEOForceData forceData_;
    
    CMMotionManager *motionManager_;
    __weak id<MEOSensorDelegate> delegate_;
}
@end


@implementation MEOSensor

@synthesize delegate = delegate_;

-(id)init{
    if (self = [super init]) {
        MEOSensorDataInit(sensorData_);
        forceData_ = MEOForceDataMake(0.0, 0.0, 0);
        
        NSTimeInterval interval = 1.0/kFrequency;
        motionManager_ = [[CMMotionManager alloc] init];
        motionManager_.accelerometerUpdateInterval = interval;
        motionManager_.gyroUpdateInterval = interval;
        motionManager_.magnetometerUpdateInterval = interval;
        motionManager_.deviceMotionUpdateInterval = interval;
    }
    return self;
}

-(void)dealloc
{
    delegate_ = nil;
    [self stopAccelerometer];
}

// MARK: - for IO

-(double)force
{
    return forceData_.current;
}

-(CMAcceleration)acceleration
{
    return sensorData_.acceleration;
}

// MARK: - for Accelerometer

-(void)startAccelerometer:(MEOSensorComletion)comletion
{
    if (motionManager_.accelerometerAvailable && motionManager_.accelerometerActive == NO) {
        sensorData_.acceleration = CMAccelerationMake(0, 0, 0);
        sensorData_.timestamp = 0.0;
        forceData_ = MEOForceDataMake(0.0, 0.0, 0);
        
        CMAccelerometerHandler handler = ^(CMAccelerometerData *accelerometerData, NSError *error)
        {
            static CMAcceleration pAcceleration;
            
            self->sensorData_.timestamp = accelerometerData.timestamp;
            if (CMAccelerationIsEqual(self->sensorData_.acceleration, CMAccelerationMake(0, 0, 0))) {
                self->sensorData_.acceleration = accelerometerData.acceleration;
                pAcceleration = CMAccelerationMake(0, 0, 0);
                self->forceData_.previous = CMAccelerationLpf(self->sensorData_.acceleration);
            }else{
                self->sensorData_.acceleration = CMAccelerationLowpassFilter(self->sensorData_.acceleration,
                                                                       pAcceleration,
                                                                       kFilteringFactor);
                self->forceData_.current = CMAccelerationLpf(self->sensorData_.acceleration);
            }
            
            if (comletion) {
                comletion(self, true);
            }
            if (self->delegate_ && [self->delegate_ respondsToSelector:@selector(measuredAccelerometer:completion:)]) {
                [self->delegate_ measuredAccelerometer:self completion:YES];
            }
            
            MEOForceDataUpdate(self->forceData_);
        };
        
        [motionManager_ startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:handler];
    }
    
}

-(void)stopAccelerometer
{
    if (motionManager_.accelerometerAvailable && motionManager_.accelerometerActive) {
        [motionManager_ stopAccelerometerUpdates];
        sensorData_.acceleration = CMAccelerationMake(0, 0, 0);
        forceData_ = MEOForceDataMake(0.0, 0.0, 0);
    }
}

-(UIDeviceOrientation)physicalOrientation
{
    CMAcceleration orient[10];
    
    orient[UIDeviceOrientationPortrait].x = 0.0;
    orient[UIDeviceOrientationPortrait].y = -1.0;
    orient[UIDeviceOrientationPortrait].z = 0.0;
    
    orient[UIDeviceOrientationPortraitUpsideDown].x = 0.0;
    orient[UIDeviceOrientationPortraitUpsideDown].y = 1.0;
    orient[UIDeviceOrientationPortraitUpsideDown].z = 0.0;
    
    orient[UIDeviceOrientationLandscapeLeft].x = -1.0;
    orient[UIDeviceOrientationLandscapeLeft].y = 0.0;
    orient[UIDeviceOrientationLandscapeLeft].z = 0.0;
    
    orient[UIDeviceOrientationLandscapeRight].x = 1.0;
    orient[UIDeviceOrientationLandscapeRight].y = 0.0;
    orient[UIDeviceOrientationLandscapeRight].z = 0.0;
    
    orient[UIDeviceOrientationFaceUp].x = 0.0;
    orient[UIDeviceOrientationFaceUp].y = 0.0;
    orient[UIDeviceOrientationFaceUp].z = -1.0;
    
    orient[UIDeviceOrientationFaceDown].x = 0.0;
    orient[UIDeviceOrientationFaceDown].y = 0.0;
    orient[UIDeviceOrientationFaceDown].z = 1.0;
    
    CMAcceleration acceleration = sensorData_.acceleration;
    double threshold = 0.5;
    
    for( int i = UIDeviceOrientationPortrait; i <= UIDeviceOrientationFaceDown; i++ ){
        float diff = sqrt((orient[i].x-acceleration.x)*(orient[i].x-acceleration.x)
                          + (orient[i].y-acceleration.y)*(orient[i].y-acceleration.y)
                          + (orient[i].z-acceleration.z)*(orient[i].z-acceleration.z) );
        if ( diff < threshold ){
            return i;
        }
    }
    
    return UIDeviceOrientationUnknown;
}

-(UIDeviceOrientation)systematicOrientation
{
    UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
    return (UIDeviceOrientation)orient;
}

-(BOOL)isScreenLock
{
    if ( [UIDevice currentDevice].orientation == UIDeviceOrientationPortrait ){
        CMAcceleration portrait = CMAccelerationMake(0.0, -1.0, 0.0);
        CMAcceleration acceleration = sensorData_.acceleration;
        double threshold = 0.5;
        
        float diff = sqrt( (portrait.x-acceleration.x)*(portrait.x-acceleration.x)
                          + (portrait.y-acceleration.y)*(portrait.y-acceleration.y)
                          + (portrait.z-acceleration.z)*(portrait.z-acceleration.z) );
        if ( diff > threshold ){
            return YES;
        }
    }
    return NO;
}

@end
