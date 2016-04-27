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


NSString *const MEOHardwareUtilKeyHeadphones = @"MEOHardwareUtilKeyHeadphones";
NSString *const MEOHardwareUtilKeyRemoteControl = @"MEOHardwareUtilKeyRemoteControl";
NSString *const MEOHardwareUtilDidChangedHeadphones = @"MEOHardwareUtilDidChangedHeadphones";
NSString *const MEOHardwareUtilDidChangeRemoteControl = @"MEOHardwareUtilDidChangeRemoteControl";

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

+ (BOOL)hasHeadphonesFromUserInfo:(NSDictionary*)userInfo
{
    BOOL hasHeadphones = false;
    if (userInfo && [userInfo.allKeys containsObject:MEOHardwareUtilKeyHeadphones]) {
        NSNumber *num = [userInfo objectForKey:MEOHardwareUtilKeyHeadphones];
        if (num) {
            hasHeadphones = [num boolValue];
        }
    }
    
    return hasHeadphones;
}

- (void)postNotificationHeadphones:(BOOL)hasHeadphones
{
    NSDictionary *dict = dict = @{MEOHardwareUtilKeyHeadphones:@(hasHeadphones)};
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:MEOHardwareUtilDidChangedHeadphones
                      object:nil
                    userInfo:dict];
}

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
    [self postNotificationHeadphones:hasHeadphones];
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(hardwareUtil:didChangedHeadphones:)]) {
        [self.delegate hardwareUtil:self
               didChangedHeadphones:hasHeadphones];
    }
}



#pragma mark - リモコン

+ (MEOHardwareUtilRemoteControl)ctrlFromUserInfo:(NSDictionary*)userInfo
{
    MEOHardwareUtilRemoteControl ctrl = MEOHardwareUtilRemoteControlNone;
    
    if (userInfo && [userInfo.allKeys containsObject:MEOHardwareUtilKeyRemoteControl]) {
        NSNumber *num = [userInfo objectForKey:MEOHardwareUtilKeyRemoteControl];
        if (num) {
            ctrl = [num integerValue];
        }
    }
    
    return ctrl;
}

- (void)postNotificationRemoteControl:(MEOHardwareUtilRemoteControl)ctrl
{
    NSDictionary *dict = dict = @{MEOHardwareUtilKeyRemoteControl:@(ctrl)};
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:MEOHardwareUtilDidChangeRemoteControl
                      object:nil
                    userInfo:dict];
}

/**
 *  イベントが再生停止トグルか再生か停止のときにtrue, それ以外はfalse
 */
+ (BOOL)isTogglePlayPause:(MEOHardwareUtilRemoteControl)ctrl
{
    BOOL result = false;
    if (ctrl == MEOHardwareUtilRemoteControlToggle
        || ctrl == MEOHardwareUtilRemoteControlPlay
        || ctrl == MEOHardwareUtilRemoteControlPause) {
        result = true;
    }
    return result;
}

- (void)rccTogglePlayPause:(MPRemoteCommandEvent*)event
{
    [self postNotificationRemoteControl:MEOHardwareUtilRemoteControlToggle];
    
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(hardwareUtil:didChangeRemoteControl:)]) {
        [self.delegate hardwareUtil:self
             didChangeRemoteControl:MEOHardwareUtilRemoteControlToggle];
    }
}

- (void)rccTogglePlay:(MPRemoteCommandEvent*)event
{
    [self postNotificationRemoteControl:MEOHardwareUtilRemoteControlPlay];
    
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(hardwareUtil:didChangeRemoteControl:)]) {
        [self.delegate hardwareUtil:self
             didChangeRemoteControl:MEOHardwareUtilRemoteControlPlay];
    }
}

- (void)rccTogglePause:(MPRemoteCommandEvent*)event
{
    [self postNotificationRemoteControl:MEOHardwareUtilRemoteControlPause];
    
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(hardwareUtil:didChangeRemoteControl:)]) {
        [self.delegate hardwareUtil:self
             didChangeRemoteControl:MEOHardwareUtilRemoteControlPause];
    }
}

- (void)rccNextTrack:(MPRemoteCommandEvent*)event
{
    [self postNotificationRemoteControl:MEOHardwareUtilRemoteControlNext];
    
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(hardwareUtil:didChangeRemoteControl:)]) {
        [self.delegate hardwareUtil:self
             didChangeRemoteControl:MEOHardwareUtilRemoteControlNext];
    }
}

- (void)rccPrevTrack:(MPRemoteCommandEvent*)event
{
    [self postNotificationRemoteControl:MEOHardwareUtilRemoteControlPrevious];
    
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(hardwareUtil:didChangeRemoteControl:)]) {
        [self.delegate hardwareUtil:self
             didChangeRemoteControl:MEOHardwareUtilRemoteControlPrevious];
    }
}


@end
