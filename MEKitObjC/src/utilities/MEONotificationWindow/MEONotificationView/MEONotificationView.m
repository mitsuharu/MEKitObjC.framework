//
//  MEONotificationView.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2014/12/17.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import "MEONotificationView.h"
#import "MEOUtilities.h"
#import <QuartzCore/QuartzCore.h>

@interface MEONotificationContent ()
{
    NSString *title_;
    NSString *message_;
    UIImage *iconImage_;
    MEONotificationCompletion completion_;
    NSString *uuid_;
}
@end

@implementation MEONotificationContent

@synthesize title = title_;
@synthesize message = message_;
@synthesize iconImage = iconImage_;
@synthesize completion = completion_;
@synthesize uuid = uuid_;

-(id)initWithTitle:(NSString*)title
           message:(NSString *)message
         iconImage:(UIImage*)iconImage
        completion:(MEONotificationCompletion)completion
{
    if (self = [super init]) {
        title_ = title;
        message_ = message;
        iconImage_ = iconImage;
        completion_ = [completion copy];
        uuid_ = [[NSUUID UUID] UUIDString];
    }
    return self;
}

-(BOOL)isEqual:(MEONotificationContent*)object
{
    BOOL equal = false;
    if ([self.uuid isEqualToString:object.uuid]) {
        equal = true;
    }
    return equal;
}

@end


@interface MEONotificationView ()
{
    IBOutlet UIView *backView_;
    IBOutlet UILabel *titleLabel_;
    IBOutlet UILabel *messageLabel_;
    IBOutlet UIImageView *iconImageView_;
    
    MEONotificationContent *content_;
    __weak id<MEONotificationViewDelegate> delegate_;
}

-(void)handleTapEvent:(UIGestureRecognizer*)gr;

@end

@implementation MEONotificationView

@synthesize content = content_;
@synthesize delegate = delegate_;

-(void)setContent:(MEONotificationContent*)content
{
    if (content) {
        content_ = content;
        titleLabel_.text = content_.title;
        messageLabel_.text = content_.message;
        if (content_.iconImage) {
            iconImageView_.image = content_.iconImage;
        }
    }
}

-(void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    
    if (titleLabel_) {
        titleLabel_.text = nil;
    }
    if (messageLabel_) {
        messageLabel_.text = nil;
    }
    if (backView_) {
        backView_.layer.cornerRadius = 10;
        backView_.clipsToBounds = true;
        backView_.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        backView_.layer.borderWidth = 1.0;
    }
    
    if (iconImageView_) {
        UIImage *image = [MEOUtilities imageOfResourceBundle:@"nw_info"];
        iconImageView_.image = image;
    }
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(handleTapEvent:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:gr];
}

-(void)handleTapEvent:(UIGestureRecognizer*)gr
{
    if (content_ && content_.completion) {
        content_.completion();
    }
    if (delegate_ && [delegate_ respondsToSelector:@selector(touchedNotificationView:)]) {
        [delegate_ touchedNotificationView:self];
    }
}


@end
