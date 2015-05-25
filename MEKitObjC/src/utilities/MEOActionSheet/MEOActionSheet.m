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
    
    id alert_;
    MEOActionSheetCompletion completion_;
}

-(void)didEnterBackground:(NSNotification*)notification;
+(BOOL)hasAlertController;

//-(void)showActionSheet:(UIActionSheet*)actionSheet
//        viewController:(UIViewController*)viewController;

@end


@implementation MEOActionSheet

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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        buttonTitles_ = [[NSMutableArray alloc] initWithCapacity:1];
        
        if ([MEOActionSheet hasAlertController]) {
            UIAlertController *alt = [UIAlertController alertControllerWithTitle:title
                                                                         message:message
                                                                  preferredStyle:(UIAlertControllerStyleActionSheet)];
            alert_ = alt;
            
            if (others && others.count > 0) {
                [buttonTitles_ addObjectsFromArray:others];
            }
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
                                                          isShowing_ = false;
                                                          if(completion){
                                                              completion(self, i);
                                                          }
                                                      }]];
            }
        }else{
            UIActionSheet *alt = [[UIActionSheet alloc] init];
            alt.delegate = self;
            alt.title = title;

            for (NSString *str in others) {
                [alt addButtonWithTitle:str];
                [buttonTitles_ addObject:str];
            }
            
            if (destructiveButtonTitle && destructiveButtonTitle.length > 0) {
                destructiveButtonIndex_ = buttonTitles_.count;
                alt.destructiveButtonIndex = destructiveButtonIndex_;
                [alt addButtonWithTitle:destructiveButtonTitle];
                [buttonTitles_ addObject:destructiveButtonTitle];
            }
            
            if (cancelButtonTitle && cancelButtonTitle.length > 0) {
                cancelButtonIndex_ = buttonTitles_.count;
                alt.cancelButtonIndex = cancelButtonIndex_;
                [alt addButtonWithTitle:cancelButtonTitle];
                [buttonTitles_ addObject:cancelButtonTitle];
            }
            
            if(completion){
                completion_ = [completion copy];
            }
            
            alert_ = alt;
        }
    });
    
    autoRemoving_ = YES;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(didEnterBackground:)
               name:UIApplicationWillResignActiveNotification
             object:nil];
    
    return self;
}

-(void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self
                  name:UIApplicationWillResignActiveNotification
                object:nil];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        isShowing_ = true;
        if ([MEOActionSheet hasAlertController]) {
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
        }else{
            UIActionSheet *av = (UIActionSheet*)alert_;
            [av showInView:viewController.view.window];
            if (completion) {
                completion();
            }
        }
    });
}


-(void)remove:(MEOActionSheetShownCompletion)completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([MEOActionSheet hasAlertController]) {
            UIAlertController *ac = (UIAlertController*)alert_;
            [ac dismissViewControllerAnimated:true
                                   completion:completion];
        }else{
            UIActionSheet *av = (UIActionSheet*)alert_;
            [av dismissWithClickedButtonIndex:-1 animated:NO];
            if (completion) {
                completion();
            }
        }
        isShowing_ = false;
    });
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    isShowing_ = false;
    if (completion_) {
        completion_(self, buttonIndex);
    }
}

+(BOOL)hasAlertController
{
    BOOL result = NO;
    Class cls = NSClassFromString(@"UIAlertController");
    if (cls != nil) {
        result = YES;
    }
    return result;
}

-(void)didEnterBackground:(NSNotification*)notification
{
    if (autoRemoving_ && isShowing_) {
        [self remove:nil];
    }
}

@end
