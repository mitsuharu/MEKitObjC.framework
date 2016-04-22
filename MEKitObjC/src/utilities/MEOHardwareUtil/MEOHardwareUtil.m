//
//  MEOHardwareUtil.m
//  HardwareCtrl
//
//  Created by Mitsuharu Emoto on 2016/04/07.
//  Copyright © 2016年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOHardwareUtil.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MEOHardwareUtil ()

@property BOOL isNotifyingHeadphone;

@end


@implementation MEOHardwareUtil


#pragma mark - lifecycle

- (id)init
{
    if (self = [super init]) {
        self.isNotifyingHeadphone = false;
    }
    return self;
}

- (void)dealloc
{
    [self removeHeadphoneNotification];
}

#pragma mark - ヘッドホンに関して

+ (BOOL)hasHeadphones
{
    BOOL hasHeadphones = false;
    
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]){
        NSString *portType = desc.portType;
        if ([portType isEqualToString:AVAudioSessionPortHeadphones]
            || [portType isEqualToString:AVAudioSessionPortBluetoothA2DP]){
            hasHeadphones = true;
        }
    }
    
    return hasHeadphones;
}



-(void)addHeadphoneNotification
{
    if (self.isNotifyingHeadphone == false) {
        
        // リモコンのイベント
        id obj = NSClassFromString(@"MPRemoteCommandCenter");
        if (obj) {
            MPRemoteCommandCenter *rcc = [MPRemoteCommandCenter sharedCommandCenter];
            [rcc.togglePlayPauseCommand addTarget:self
                                           action:@selector(rccTogglePlayPause:)];
            [rcc.playCommand addTarget:self
                                action:@selector(rccTogglePlay:)];
            [rcc.pauseCommand addTarget:self
                                 action:@selector(rccTogglePause:)];
            [rcc.nextTrackCommand addTarget:self
                                     action:@selector(rccNextTrack:)];
            [rcc.previousTrackCommand addTarget:self
                                         action:@selector(rccPrevTrack:)];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(audioSessionRouteChanged:)
                                                     name:AVAudioSessionRouteChangeNotification
                                                   object:[AVAudioSession sharedInstance]];
        self.isNotifyingHeadphone = true;
    }
}

-(void)removeHeadphoneNotification
{
    if (self.isNotifyingHeadphone) {
        
        // リモコンのイベント
        id obj = NSClassFromString(@"MPRemoteCommandCenter");
        if (obj) {
            MPRemoteCommandCenter *rcc = [MPRemoteCommandCenter sharedCommandCenter];
            [rcc.togglePlayPauseCommand removeTarget:self];
            [rcc.playCommand removeTarget:self];
            [rcc.pauseCommand removeTarget:self];
            [rcc.nextTrackCommand removeTarget:self];
            [rcc.previousTrackCommand removeTarget:self];
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVAudioSessionRouteChangeNotification
                                                      object:[AVAudioSession sharedInstance]];
        self.isNotifyingHeadphone = false;
    }
}


/**
 *  端末にヘッドホンを付けているか調べる
 */
- (void)audioSessionRouteChanged:(NSNotification*)notification
{
    BOOL hasHeadphones = [MEOHardwareUtil hasHeadphones];
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(hardwareUtil:didChangedHeadphone:)]) {
        [self.delegate hardwareUtil:self
             didChangedHeadphone:hasHeadphones];
    }
}



#pragma mark - リモコン

/**
 *  イベントが再生停止トグルか再生か停止のときにtrue, それ以外はfalse
 */
+ (BOOL)isTogglePlayPause:(MEOHardwareUtilRemoteControl)ctrl
{
    BOOL result = false;
    if (ctrl == MEOHardwareUtilRemoteControlTogglePlayPause
        || ctrl == MEOHardwareUtilRemoteControlPlay
        || ctrl == MEOHardwareUtilRemoteControlPause) {
        result = true;
    }
    return result;
}

- (void)rccTogglePlayPause:(MPRemoteCommandEvent*)event
{
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(hardwareUtil:didChangeRemoteControl:)]) {
        [self.delegate hardwareUtil:self
             didChangeRemoteControl:MEOHardwareUtilRemoteControlTogglePlayPause];
    }
}

- (void)rccTogglePlay:(MPRemoteCommandEvent*)event
{
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(hardwareUtil:didChangeRemoteControl:)]) {
        [self.delegate hardwareUtil:self
             didChangeRemoteControl:MEOHardwareUtilRemoteControlPlay];
    }
}

- (void)rccTogglePause:(MPRemoteCommandEvent*)event
{
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(hardwareUtil:didChangeRemoteControl:)]) {
        [self.delegate hardwareUtil:self
             didChangeRemoteControl:MEOHardwareUtilRemoteControlPause];
    }
}

- (void)rccNextTrack:(MPRemoteCommandEvent*)event
{
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(hardwareUtil:didChangeRemoteControl:)]) {
        [self.delegate hardwareUtil:self
             didChangeRemoteControl:MEOHardwareUtilRemoteControlNextTrack];
    }
}

- (void)rccPrevTrack:(MPRemoteCommandEvent*)event
{
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(hardwareUtil:didChangeRemoteControl:)]) {
        [self.delegate hardwareUtil:self
             didChangeRemoteControl:MEOHardwareUtilRemoteControlPreviousTrack];
    }
}


@end
