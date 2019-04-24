//
//  MEOAlertView.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/02/06.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOAlertView.h"

@interface MEOAlertView () < UIAlertViewDelegate >
{
    NSInteger tag_;
    NSMutableArray *buttonTitles_;
    NSInteger cancelButtonIndex_;
    BOOL isShowing_;
    BOOL autoRemoving_;
    BOOL hasNotification_;
    
    id alert_;
    MEOAlertViewCompletion completion_;
    
    MEOAlertViewRemovedCompletion autoRemovedCompletion_;
}

-(void)didEnterBackground:(NSNotification*)notification;

@end

@implementation MEOAlertView

@synthesize autoRemovedCompletion = autoRemovedCompletion_;
@synthesize autoRemoving = autoRemoving_;
@synthesize tag = tag_;
@synthesize buttonTitles = buttonTitles_;
@synthesize isShowing = isShowing_;
@synthesize cancelButtonIndex = cancelButtonIndex_;

-(id)initWithTitle:(NSString *)title
           message:(NSString *)message
        completion:(MEOAlertViewCompletion)completion
 cancelButtonTitle:(NSString *)cancelButtonTitle
 otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    NSMutableArray *others = [[NSMutableArray alloc] initWithCapacity:1];
    va_list args;
    va_start(args, otherButtonTitles);
    for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*)) {
        [others addObject:arg];
    }
    va_end(args);
    
    self.title = title;
    self.message = message;
    buttonTitles_ = [[NSMutableArray alloc] initWithCapacity:1];
    
    UIAlertController *alt = [UIAlertController alertControllerWithTitle:title
                                                                 message:message
                                                          preferredStyle:(UIAlertControllerStyleAlert)];
    alert_ = alt;
    
    if (cancelButtonTitle && cancelButtonTitle.length > 0) {
        cancelButtonIndex_ = buttonTitles_.count;
        [buttonTitles_ addObject:cancelButtonTitle];
    }
    if (others && others.count > 0) {
        [buttonTitles_ addObjectsFromArray:others];
    }
    
    for (int i = 0; i < buttonTitles_.count; i++) {
        NSString *str = [buttonTitles_ objectAtIndex:i];
        UIAlertActionStyle style = UIAlertActionStyleDefault;
        if (i == cancelButtonIndex_) {
            style = UIAlertActionStyleCancel;
        }
        [alt addAction:[UIAlertAction actionWithTitle:str
                                                style:style
                                              handler:^(UIAlertAction *action) {
                                                  self->isShowing_ = false;
                                                  if(completion){
                                                      completion(self, i);
                                                  }
                                              }]];
    }
    
    autoRemoving_ = false;
    
    return self;
}

-(void)setAutoRemoving:(BOOL)autoRemoving
 autoRemovedCompletion:(MEOAlertViewRemovedCompletion)autoRemovedCompletion
{
    autoRemoving_ = autoRemoving;
    
    if (autoRemovedCompletion) {
        autoRemovedCompletion_ = [autoRemovedCompletion copy];
    }else{
        autoRemovedCompletion_ = nil;
    }
}



-(void)clear
{
    if (isShowing_) {
        [self remove:nil];
    }
    
    if (hasNotification_) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self
                      name:UIApplicationWillResignActiveNotification
                    object:nil];
        hasNotification_ = false;
    }
    autoRemovedCompletion_ = nil;
    
    if (buttonTitles_) {
        [buttonTitles_ removeAllObjects];
        buttonTitles_ = nil;
    }
    alert_ = nil;
    completion_ = nil;
}

-(void)dealloc
{
    [self clear];
}

-(void)show:(MEOAlertViewShownCompletion)completion
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *vc = window.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }

    [self show:vc
    completion:completion];
}

-(void)show:(UIViewController*)viewController
 completion:(MEOAlertViewShownCompletion)completion
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(didEnterBackground:)
               name:UIApplicationWillResignActiveNotification
             object:nil];
    hasNotification_ = true;
    
    isShowing_ = true;
    UIAlertController *ac = (UIAlertController*)alert_;
    if (viewController) {
        [viewController presentViewController:ac
                                     animated:true
                                   completion:^{
                                       if (completion) {
                                           completion();
                                       }
                                   }];
    }
}

-(void)remove:(MEOAlertViewRemovedCompletion)completion
{
    if (hasNotification_) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self
                      name:UIApplicationWillResignActiveNotification
                    object:nil];
        hasNotification_ = false;
    }
    
    UIAlertController *ac = (UIAlertController*)alert_;
    [ac dismissViewControllerAnimated:true
                           completion:completion];
    isShowing_ = false;
}


-(void)didEnterBackground:(NSNotification*)notification
{
    if (autoRemoving_ && isShowing_) {
        [self remove:autoRemovedCompletion_];
    }
}

@end
