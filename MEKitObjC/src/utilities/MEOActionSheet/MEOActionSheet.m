//
//  MEOActionSheet.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/04/03.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOActionSheet.h"

@interface MEOActionSheet () < UIActionSheetDelegate >
{
    NSInteger tag_;
    NSMutableArray *buttonTitles_;
    NSInteger cancelButtonIndex_;
    NSInteger destructiveButtonIndex_;
    BOOL isShowing_;
    BOOL autoRemoving_;
    BOOL hasNotification_;
    
    id alert_;
    MEOActionSheetCompletion completion_;
    MEOActionSheetRemovedCompletion autoRemovedCompletion_;
}

-(void)didEnterBackground:(NSNotification*)notification;

//-(void)showActionSheet:(UIActionSheet*)actionSheet
//        viewController:(UIViewController*)viewController;

@end


@implementation MEOActionSheet

@synthesize autoRemovedCompletion = autoRemovedCompletion_;
@synthesize autoRemoving = autoRemoving_;
@synthesize tag = tag_;
@synthesize buttonTitles = buttonTitles_;
@synthesize isShowing = isShowing_;
@synthesize cancelButtonIndex = cancelButtonIndex_;
@synthesize destructiveButtonIndex = destructiveButtonIndex_;

-(id)initWithTitle:(NSString *)title
           message:(NSString *)message
        completion:(MEOActionSheetCompletion)completion
 cancelButtonTitle:(NSString *)cancelButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
 otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    NSMutableArray *others = [[NSMutableArray alloc] initWithCapacity:1];
    va_list args;
    va_start(args, otherButtonTitles);
    for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*)) {
        [others addObject:arg];
    }
    va_end(args);
    
    buttonTitles_ = [[NSMutableArray alloc] initWithCapacity:1];
    
    UIAlertController *alt = [UIAlertController alertControllerWithTitle:title
                                                                 message:message
                                                          preferredStyle:(UIAlertControllerStyleActionSheet)];
    alert_ = alt;
    
    if (others && others.count > 0) {
        [buttonTitles_ addObjectsFromArray:others];
    }
    
    destructiveButtonIndex_ = -1;
    if (destructiveButtonTitle && destructiveButtonTitle.length > 0) {
        destructiveButtonIndex_ = buttonTitles_.count;
        [buttonTitles_ addObject:destructiveButtonTitle];
    }
    
    if (cancelButtonTitle && cancelButtonTitle.length > 0) {
        cancelButtonIndex_ = buttonTitles_.count;
        [buttonTitles_ addObject:cancelButtonTitle];
    }
    
    for (int i = 0; i < buttonTitles_.count; i++) {
        NSString *str = [buttonTitles_ objectAtIndex:i];
        UIAlertActionStyle style = UIAlertActionStyleDefault;
        if (i == cancelButtonIndex_) {
            style = UIAlertActionStyleCancel;
        }else if (i == destructiveButtonIndex_) {
            style = UIAlertActionStyleDestructive;
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
    }
    autoRemovedCompletion_ = nil;
    
    if (buttonTitles_) {
        [buttonTitles_ removeAllObjects];
        buttonTitles_ = nil;
    }
    
    alert_ = nil;
    completion_ = nil;
}


-(void)setAutoRemoving:(BOOL)autoRemoving
 autoRemovedCompletion:(MEOActionSheetRemovedCompletion)autoRemovedCompletion
{
    autoRemoving_ = autoRemoving;
    
    if (autoRemovedCompletion) {
        autoRemovedCompletion_ = [autoRemovedCompletion copy];
    }else{
        autoRemovedCompletion_ = nil;
    }
}

-(void)dealloc
{
    [self clear];
}

-(void)show:(MEOActionSheetShownCompletion)completion
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
 completion:(MEOActionSheetShownCompletion)completion
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


-(void)remove:(MEOActionSheetShownCompletion)completion
{
    if (hasNotification_) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self
                      name:UIApplicationWillResignActiveNotification
                    object:nil];
    }
    autoRemovedCompletion_ = nil;
    
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
