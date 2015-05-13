//
//  MEONotificationView.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2014/12/17.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEONotificationWindow.h"

#define kNotificationViewHeight    44.0f

@class MEONotificationView;

@interface MEONotificationContent : NSObject
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) UIImage *iconImage;
@property (nonatomic, copy) MEONotificationCompletion completion;
@property (nonatomic, retain) NSString *uuid;

-(id)initWithTitle:(NSString*)title
           message:(NSString *)message
         iconImage:(UIImage*)iconImage
        completion:(MEONotificationCompletion)completion;
-(BOOL)isEqual:(MEONotificationContent*)object;

@end

@protocol MEONotificationViewDelegate <NSObject>
@optional
-(void)touchedNotificationView:(MEONotificationView*)notificationView;
@end

@interface MEONotificationView : UIView

-(void)setContent:(MEONotificationContent*)content;

@property (nonatomic, retain, setter=setContent:) MEONotificationContent *content;
@property (nonatomic, weak) id<MEONotificationViewDelegate> delegate;

@end
