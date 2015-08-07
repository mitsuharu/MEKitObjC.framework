//
//  MEOCaptureSessionManager.h
//  
//
//  Created by Mitsuharu Emoto on 2015/07/21.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class MEOCaptureSessionManager;

#pragma mark - UIImage (CaptureSession)

@interface UIImage (CaptureSession)

-(UIImage*)mirrored;
-(UIImage*)turned;

@end

#pragma mark - MEOCaptureSessionManagerDelegate

@protocol MEOCaptureSessionManagerDelegate <NSObject>

-(void)captureSessionManager:(MEOCaptureSessionManager*)manager
               capturedimage:(UIImage*)capturedimage;

@end

#pragma mark - MEOCaptureSessionManager

@interface MEOCaptureSessionManager : NSObject

@property (nonatomic, weak) id<MEOCaptureSessionManagerDelegate> delegate;

+(BOOL)openSettingApp;
+(BOOL)isCameraAvailable;
+(void)authorizeCameraAccess:(void(^)(BOOL granted))completion;


-(id)initWithCaptureDevicePosition:(AVCaptureDevicePosition)position;
-(void)start;
-(void)stop;

@end
