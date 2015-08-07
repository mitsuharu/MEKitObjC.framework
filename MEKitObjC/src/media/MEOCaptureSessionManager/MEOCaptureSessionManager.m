//
//  MEOCaptureSessionManager.m
//  SampleAVCaptureApp
//
//  Created by Mitsuharu Emoto on 2015/07/21.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOCaptureSessionManager.h"
#import <AVFoundation/AVFoundation.h>

#pragma mark - UIImage (CaptureSession)

@implementation UIImage (CaptureSession)

-(UIImage*)mirrored
{
    CGImageRef imgRef = [self CGImage];
    
    UIGraphicsBeginImageContext(self.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM( context, self.size.width, self.size.height);
    CGContextScaleCTM( context, -1.0, -1.0);
    CGContextDrawImage( context, CGRectMake( 0, 0, self.size.width, self.size.height), imgRef);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(UIImage*)turned
{
    UIGraphicsBeginImageContext(CGSizeMake(self.size.height, self.size.width));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        CGContextScaleCTM(context, 1, -1);
        CGContextRotateCTM(context, -M_PI_2);
    }else{
        CGContextTranslateCTM(context, self.size.height, self.size.width);
        CGContextScaleCTM(context, 1, -1);
        CGContextRotateCTM(context, M_PI_2);
    }
    
    CGContextDrawImage(context,
                       CGRectMake( 0, 0, self.size.width, self.size.height),
                       [self CGImage]);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(UIImage*)clockwiseMirrored
{
    UIImage *image  = [[self mirrored] turned];
    return image;
}

@end

#pragma mark - MEOCaptureSessionManager

@interface MEOCaptureSessionManager ()
<
    AVCaptureVideoDataOutputSampleBufferDelegate
>
{
    AVCaptureDevicePosition position_;
    AVCaptureSession *session_;
    AVCaptureDevice *device_;
    AVCaptureDeviceInput *input_;
    AVCaptureVideoDataOutput *output_;
    AVCaptureConnection *connection_;
}

+(AVCaptureDevice*)captureDevice:(AVCaptureDevicePosition)position;


-(void)setup;

@end

@implementation MEOCaptureSessionManager

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

+(void)authorizeCameraAccess:(void(^)(BOOL granted))completion
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

+(AVCaptureDevice*)captureDevice:(AVCaptureDevicePosition)position
{
    AVCaptureDevice *device = nil;
    for (AVCaptureDevice *camera in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if (camera.position == position) {
            device = camera;
        }
    }
    return device;
}


-(id)init
{
    if (self = [super init]) {
        position_ = AVCaptureDevicePositionBack;
#if(TARGET_IPHONE_SIMULATOR)
#else
        [self setup];
#endif
    }
    return self;
}

-(id)initWithCaptureDevicePosition:(AVCaptureDevicePosition)position
{
    if (self = [super init]) {
        position_ = position;
        
#if(TARGET_IPHONE_SIMULATOR)
#else
        [self setup];
#endif
    }
    return self;
}


-(void)dealloc
{
    [self stop];
}

-(void)setup
{
    NSLog(@"%s", __func__);
    
    device_ = [MEOCaptureSessionManager captureDevice:position_];
    input_ = [AVCaptureDeviceInput deviceInputWithDevice:device_
                                                   error:nil];
    
    //ビデオデータ出力作成
    NSDictionary* settings = @{(id)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]};
    output_ = [[AVCaptureVideoDataOutput alloc] init];
    output_.videoSettings = settings;
    [output_ setSampleBufferDelegate:self
                               queue:dispatch_get_main_queue()];
    
    //セッション作成
    session_ = [[AVCaptureSession alloc] init];
    [session_ addInput:input_];
    [session_ addOutput:output_];
    session_.sessionPreset = AVCaptureSessionPresetHigh;
    
    // カメラの向きなどを設定する
    [session_ beginConfiguration];
    
    for(AVCaptureConnection *connection in [output_ connections]){
        for(AVCaptureInputPort *port in [connection inputPorts]){
            if ([[port mediaType] isEqual:AVMediaTypeVideo]){
                connection_ = connection;
            }
        }
    }
    
    if(connection_ && [connection_ isVideoOrientationSupported]){
        [connection_ setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
    
    [session_ commitConfiguration];
}


-(void)start
{
    if (session_ && session_.running == false) {
        [session_ startRunning];
    }
}

-(void)stop
{
    if (session_ && session_.running) {
        [session_ stopRunning];
    }
}


//delegateメソッド。各フレームにおける処理
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    UIImage *image = [self imageFromSampleBufferRef:sampleBuffer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate
            && [self.delegate respondsToSelector:@selector(captureSessionManager:capturedimage:)]) {
            [self.delegate captureSessionManager:self
                                   capturedimage:image];
        }
    });
    
}

// CMSampleBufferRefをUIImageへ
- (UIImage *)imageFromSampleBufferRef:(CMSampleBufferRef)sampleBuffer
{
    // イメージバッファの取得
    CVImageBufferRef    buffer;
    buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // イメージバッファのロック
    CVPixelBufferLockBaseAddress(buffer, 0);
    // イメージバッファ情報の取得
    uint8_t*    base;
    size_t      width, height, bytesPerRow;
    base = CVPixelBufferGetBaseAddress(buffer);
    width = CVPixelBufferGetWidth(buffer);
    height = CVPixelBufferGetHeight(buffer);
    bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    
    // ビットマップコンテキストの作成
    CGColorSpaceRef colorSpace;
    CGContextRef    cgContext;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    cgContext = CGBitmapContextCreate(
                                      base, width, height, 8, bytesPerRow, colorSpace,
                                      kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    // 画像の作成
    CGImageRef  cgImage;
    UIImage*    image;
    cgImage = CGBitmapContextCreateImage(cgContext);
    image = [UIImage imageWithCGImage:cgImage scale:1.0f
                          orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    CGContextRelease(cgContext);
    
    // イメージバッファのアンロック
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    return image;
}

@end
