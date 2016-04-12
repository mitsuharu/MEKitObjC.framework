//
//  UIViewController+HeadphoneEvents.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2016/04/07.
//  Copyright © 2016年 Mitsuharu Emoto. All rights reserved.
//

#import "UIViewController+HeadphoneNotification.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

BOOL isNotifyingHeadphoneEvents = false;

@implementation UIViewController (HeadphoneNotification)

//- (BOOL)canBecomeFirstResponder
//{
//    return true;
//}

- (BOOL)hasHeadphone
{
    BOOL hasHeadphones = false;
    
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]){
        NSString *portType = desc.portType;
        if ([portType isEqualToString:AVAudioSessionPortHeadphones]){
            hasHeadphones = true;
        }
        else if ([portType isEqualToString:AVAudioSessionPortBluetoothA2DP]){
            hasHeadphones = true;
        }
    }
    
    return hasHeadphones;
}

/**
 *  イベントが再生停止トグルか再生か停止のときにtrue, それ以外はfalse
 */
- (BOOL)isTogglePlayPause:(MEORemoteControlEvent)event
{
    BOOL result = false;
    
    if (event == MEORemoteControlEventTogglePlayPause
        || event == MEORemoteControlEventPlay
        || event == MEORemoteControlEventPause) {
        result = true;
    }
    
    return result;
}

/**
 *  リモコンイベントのインスタンスから状態を取得する
 */
- (MEORemoteControlEvent)convertMEORemoteControlEvent:(UIEvent*)receivedEvent
{
    MEORemoteControlEvent event = MEORemoteControlEventNone;
    
    if (receivedEvent && receivedEvent.type == UIEventTypeRemoteControl) {
        UIEventSubtype subtype = receivedEvent.subtype;

        if (subtype == UIEventSubtypeRemoteControlPlay
            || subtype == UIEventSubtypeRemoteControlPause
            || subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
            event = MEORemoteControlEventTogglePlayPause;
        }else if (subtype == UIEventSubtypeRemoteControlPreviousTrack){
            event = MEORemoteControlEventPreviousTrack;
        }else if (subtype == UIEventSubtypeRemoteControlNextTrack){
            event = MEORemoteControlEventNextTrack;
        }
    }
    
    return event;
}


- (void)addHeadphoneNotification
{
    if (isNotifyingHeadphoneEvents == false) {
        isNotifyingHeadphoneEvents = true;
        
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
        }else{
            [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
            [self becomeFirstResponder];
        }
        
        // マイクの差し抜き
        [[AVAudioSession sharedInstance] setActive:true
                                             error:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(audioSessionRouteChanged:)
                                                     name:AVAudioSessionRouteChangeNotification
                                                   object:[AVAudioSession sharedInstance]];
        
        [self audioSessionRouteChanged:nil];
    }
}

- (void)removeHeadphoneNotification
{
    if (isNotifyingHeadphoneEvents) {
        isNotifyingHeadphoneEvents = true;
        
        // リモコンのイベント
        id obj = NSClassFromString(@"MPRemoteCommandCenter");
        if (obj) {
            MPRemoteCommandCenter *rcc = [MPRemoteCommandCenter sharedCommandCenter];
            [rcc.togglePlayPauseCommand removeTarget:self];
            [rcc.playCommand removeTarget:self];
            [rcc.pauseCommand removeTarget:self];
            [rcc.nextTrackCommand removeTarget:self];
            [rcc.previousTrackCommand removeTarget:self];
        }else{
            [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
            [self resignFirstResponder];
        }
        
        // マイクの差し抜き
        [[AVAudioSession sharedInstance] setActive:false
                                             error:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVAudioSessionRouteChangeNotification
                                                      object:[AVAudioSession sharedInstance]];
    }
}

- (void)remoteControlReceivedWithEvent:(UIEvent*)receivedEvent
{
    if ([self respondsToSelector:@selector(meoRemoteControlEventChanged:)]) {
        id<MEOHeadphoneNotification> this = (id<MEOHeadphoneNotification>)self;
        if (this) {
            MEORemoteControlEvent event = [self convertMEORemoteControlEvent:receivedEvent];
            [this meoRemoteControlEventChanged:event];
        }
    }
}


/**
 *  端末にヘッドホンを付けているか調べる
 */
- (void)audioSessionRouteChanged:(NSNotification*)notification
{
    if ([self respondsToSelector:@selector(meoHeadphoneChanged:)]) {
        id<MEOHeadphoneNotification> this = (id<MEOHeadphoneNotification>)self;
        if (this) {
            BOOL hasHeadphone = [self hasHeadphone];
            [this meoHeadphoneChanged:hasHeadphone];
        }
    }
}


#pragma mark - MPRemoteCommandCenter

- (void)rccTogglePlayPause:(MPRemoteCommandEvent*)event
{
    if ([self respondsToSelector:@selector(meoRemoteControlEventChanged:)]) {
        id<MEOHeadphoneNotification> this = (id<MEOHeadphoneNotification>)self;
        if (this) {
            [this meoRemoteControlEventChanged:MEORemoteControlEventTogglePlayPause];
        }
    }
}

- (void)rccTogglePlay:(MPRemoteCommandEvent*)event
{
    if ([self respondsToSelector:@selector(meoRemoteControlEventChanged:)]) {
        id<MEOHeadphoneNotification> this = (id<MEOHeadphoneNotification>)self;
        if (this) {
            [this meoRemoteControlEventChanged:MEORemoteControlEventPlay];
        }
    }

}

- (void)rccTogglePause:(MPRemoteCommandEvent*)event
{
    if ([self respondsToSelector:@selector(meoRemoteControlEventChanged:)]) {
        id<MEOHeadphoneNotification> this = (id<MEOHeadphoneNotification>)self;
        if (this) {
            [this meoRemoteControlEventChanged:MEORemoteControlEventPause];
        }
    }
}

- (void)rccNextTrack:(MPRemoteCommandEvent*)event
{
    if ([self respondsToSelector:@selector(meoRemoteControlEventChanged:)]) {
        id<MEOHeadphoneNotification> this = (id<MEOHeadphoneNotification>)self;
        if (this) {
            [this meoRemoteControlEventChanged:MEORemoteControlEventNextTrack];
        }
    }

}

- (void)rccPrevTrack:(MPRemoteCommandEvent*)event
{
    if ([self respondsToSelector:@selector(meoRemoteControlEventChanged:)]) {
        id<MEOHeadphoneNotification> this = (id<MEOHeadphoneNotification>)self;
        if (this) {
            [this meoRemoteControlEventChanged:MEORemoteControlEventPreviousTrack];
        }
    }
}


@end
