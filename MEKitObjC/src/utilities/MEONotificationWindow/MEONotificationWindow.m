//
//  MEONotificationWindow.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2014/12/17.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import "MEONotificationWindow.h"
#import "MEONotificationView.h"
#import "MEOUtilities.h"

#define kNotificationTag 949
#define RADIANS(deg) ((deg) * M_PI / 180.0f)

static MEONotificationWindow *notificationWindow_ = nil;
static NSMutableArray *notificationContentArray_ = nil;

@interface MEONotificationWindow () <MEONotificationViewDelegate>
{
    MEONotificationView *notificationView_;
    BOOL isVisible_;
}

-(id)initWithTitle:(NSString*)title
          messsage:(NSString*)messsage
              icon:(UIImage*)icon
           touched:(MEONotificationCompletion)touched;

-(BOOL)isVisible;
-(void)showAnimated:(BOOL)animated completion:(MEONotificationCompletion)completion;
-(void)removeAnimated:(BOOL)animated completion:(MEONotificationCompletion)completion;

+(void)showNextNotificationView;

@end

@implementation MEONotificationWindow

-(id)initWithTitle:(NSString*)title
          messsage:(NSString*)messsage
              icon:(UIImage*)icon
           touched:(MEONotificationCompletion)touched
{
    if(self = [super initWithFrame:[MEONotificationWindow notificationRect]]){
        
        self.windowLevel = UIWindowLevelStatusBar + 1;
        
        isVisible_ = NO;
        self.backgroundColor = [UIColor clearColor];
        self.tag = kNotificationTag;
        
        MEONotificationContent *content = [[MEONotificationContent alloc] initWithTitle:title
                                                                                message:messsage
                                                                              iconImage:icon
                                                                             completion:touched];
        UINib *nib = nil;
        @try {
            NSBundle *bundle = [MEOUtilities resourceBundle];
            if (bundle) {
                if (title && title.length > 0) {
                    nib = [UINib nibWithNibName:@"MEONotificationView" bundle:bundle];
                }else{
                    nib = [UINib nibWithNibName:@"MEONotificationViewWithoutTitle" bundle:bundle];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%s, exception %@", __func__, exception.description);
        }
        @finally {
        }
        
        if (nib) {
            notificationView_ = [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
            notificationView_.delegate = self;
            [notificationView_ setFrame:self.frame];
            [notificationView_ setContent:content];
            [self addSubview:notificationView_];
            [self rotated];
        }else{
            notificationView_ = [[MEONotificationView alloc] initWithFrame:self.frame];
            notificationView_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            notificationView_.delegate = self;
            UILabel *label = [[UILabel alloc] initWithFrame:self.frame];
            label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            label.backgroundColor = [UIColor clearColor];
            label.text = content.message;
            [notificationView_ addSubview:label];
            [self addSubview:notificationView_];
            [self rotated];
        }
    }
    return self;
}

- (void)rotated
{
    CGRect frame = self.frame;
    CGSize screenSize = [MEONotificationWindow screenSize];
    UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (UIInterfaceOrientationIsPortrait(orient)){
        if (orient == UIDeviceOrientationPortraitUpsideDown){
            frame.origin.y = screenSize.height - kNotificationViewHeight;
            self.transform = CGAffineTransformMakeRotation(RADIANS(180.0f));
        }else{
            self.transform = CGAffineTransformIdentity;
        }
    }
    else{
        frame.size.height = frame.size.width;
        frame.size.width  = kNotificationViewHeight;
        
        if (orient == UIDeviceOrientationLandscapeLeft){
            frame.origin.x = screenSize.height - kNotificationViewHeight;
            frame.origin.y = 0;
            self.transform = CGAffineTransformMakeRotation(RADIANS(90.0f));
        }
        else if (orient == UIDeviceOrientationLandscapeRight){
            self.transform = CGAffineTransformMakeRotation(RADIANS(-90.0f));
        }
        else{
            self.transform = CGAffineTransformMakeRotation(RADIANS(-90.0f));
        }
    }

    self.frame = frame;
}


+(CGRect)notificationRect
{
    CGSize screenSize = [MEONotificationWindow screenSize];
    CGFloat height = kNotificationViewHeight;
    CGRect rect = CGRectMake(0.0f, 0.0f, screenSize.width, height);
    return rect;
}

+(CGSize)screenSize
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIApplication *app = [UIApplication sharedApplication];
    UIInterfaceOrientation orient = [app statusBarOrientation];
    if ((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
        && UIInterfaceOrientationIsLandscape(orient)) {
        return CGSizeMake(screenSize.height, screenSize.width);
    }
    return screenSize;
}


-(BOOL)isVisible
{
    return isVisible_;
}


-(void)touchedNotificationView:(MEONotificationView *)notificationView
{
//    NSLog(@"%s", __func__);
    if (notificationContentArray_ && notificationContentArray_.count > 0) {
        [notificationContentArray_ removeAllObjects];
    }
    
    [self removeAnimated:true completion:^{
    }];
}


-(void)showAnimated:(BOOL)animated completion:(MEONotificationCompletion)completion
{
    if (isVisible_) {
        return;
    }
    
    CATransform3D transform = CATransform3DMakeRotation(M_PI*(3.0/4.0), 1.0, 0.0, 0.0);
    
    
    [self makeKeyAndVisible];
    
    notificationView_.alpha = 0.0;
    notificationView_.layer.transform = transform;
    
    NSTimeInterval interval = 0.0;
    if (animated) {
        interval = 0.7;
    }
    
    [UIView animateWithDuration:interval
                     animations:^{
                         self->notificationView_.alpha = 1.0;
                         self->notificationView_.layer.transform = CATransform3DIdentity;
                     }
                     completion:^(BOOL finished) {
                         self->isVisible_ = YES;
                         
                         if (completion) {
                             completion();
                         }
                         
                         dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW,
                                                              3.0 * (NSTimeInterval)NSEC_PER_SEC);
                         dispatch_after(when, dispatch_get_main_queue(), ^{
                             [self removeAnimated:true
                                       completion:^{
                             }];
                         });
                     }];
}

-(void)removeAnimated:(BOOL)animated
           completion:(MEONotificationCompletion)completion
{
    if (self && isVisible_) {
        
        static BOOL isRemoving = false;
        if (isRemoving) {
            return;
        }
        isRemoving = true;
        
        CATransform3D transform = CATransform3DMakeRotation(M_PI*(3.0/4.0), 1.0, 0.0, 0.0);

        notificationView_.alpha = 1.0;
        notificationView_.layer.transform = CATransform3DIdentity;

        NSTimeInterval interval = 0.0;
        if (animated) {
            interval = 0.7;
        }
        
        [UIView animateWithDuration:interval
                         animations:^{
                             self->notificationView_.layer.transform = transform;
                             self->notificationView_.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             self->notificationView_.layer.transform = CATransform3DIdentity;
                             
                             NSArray *windows = [[UIApplication sharedApplication] windows];
                             for (UIWindow *window in windows) {
                                 if (window.tag == kNotificationTag || window == self) {
                                     window.hidden = YES;
                                 }
                             }
                             
                             NSInteger index = [windows indexOfObject:self];
                             if ( index != NSNotFound && 0 <= index -1 ) {
                                 UIWindow *window = [windows objectAtIndex:(index-1)];
                                 [window makeKeyAndVisible];
                             }else{
                                 UIWindow *window = windows.firstObject;
                                 [window makeKeyAndVisible];
                             }
                             
                             self->isVisible_ = NO;
                             isRemoving = false;
                             
                             if (completion) {
                                 completion();
                             }
                             
                             dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW,
                                                                  0.5 * (NSTimeInterval)NSEC_PER_SEC);
                             dispatch_after(when, dispatch_get_main_queue(), ^{
                                 [MEONotificationWindow showNextNotificationView];
                             });
                         }];
    }
}

+(BOOL)isVisible
{
    BOOL result = false;
    if (notificationWindow_ && [notificationWindow_ isVisible]) {
        result = true;
    }
    return result;
}

+(void)showWithTitle:(NSString*)title
            messsage:(NSString*)messsage
                icon:(UIImage*)icon
             touched:(MEONotificationCompletion)touched
{
    [MEONotificationWindow showWithTitle:title
                                messsage:messsage
                                    icon:icon
                                 touched:touched
                              allowQueue:true];
}

+(void)showWithTitle:(NSString*)title
            messsage:(NSString*)messsage
                icon:(UIImage*)icon
             touched:(MEONotificationCompletion)touched
          allowQueue:(BOOL)allowQueue
{
    static BOOL isShowing = false;
    if (isShowing || [MEONotificationWindow isVisible]) {
        
        MEONotificationContent *content = [[MEONotificationContent alloc] initWithTitle:title
                                                                                message:messsage
                                                                              iconImage:icon
                                                                             completion:touched];
        
        if (notificationContentArray_ == nil) {
            notificationContentArray_ = [[NSMutableArray alloc] initWithCapacity:1];
        }
        
        if (allowQueue && [notificationContentArray_ containsObject:content] == NO) {
            [notificationContentArray_ addObject:content];
        }
        
        return;
    }
    isShowing = true;
    
    [MEONotificationWindow remove];
    
    notificationWindow_ = [[MEONotificationWindow alloc] initWithTitle:title
                                                              messsage:messsage
                                                                  icon:icon
                                                               touched:touched];
    [notificationWindow_ showAnimated:true
                           completion:^{
                               isShowing = false;
    }];
}

+(void)showNextNotificationView
{
    if (notificationContentArray_ && notificationContentArray_.count > 0) {
        MEONotificationContent *content = [notificationContentArray_ firstObject];
        [MEONotificationWindow showWithTitle:content.title
                                    messsage:content.message
                                        icon:content.iconImage
                                     touched:content.completion];
        [notificationContentArray_ removeObjectAtIndex:0];
    }
}

+(void)remove
{
    if (notificationWindow_ && [notificationWindow_ isVisible]) {
        [notificationWindow_ removeAnimated:true
                                 completion:^{
                                     notificationWindow_ = nil;
        }];
    }
}

@end
