//
//  MEOAlertView.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/02/06.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MEOAlertView;

typedef void (^MEOAlertViewCompletion)(MEOAlertView *alertView, NSInteger buttonIndex);
typedef void (^MEOAlertViewShownCompletion)();
typedef void (^MEOAlertViewRemovedCompletion)();

@interface MEOAlertView : NSObject

@property (nonatomic) NSInteger tag;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain, readonly) NSMutableArray *buttonTitles;
@property (nonatomic, readonly) NSInteger cancelButtonIndex;
@property (nonatomic, readonly) BOOL isShowing;

@property (nonatomic) BOOL autoRemoving;
@property (nonatomic, copy) MEOAlertViewRemovedCompletion autoRemovedCompletion;


-(id)initWithTitle:(NSString *)title
           message:(NSString *)message
        completion:(MEOAlertViewCompletion)completion
 cancelButtonTitle:(NSString *)cancelButtonTitle
 otherButtonTitles:(NSString *)otherButtonTitles, ...;

-(void)show:(MEOAlertViewShownCompletion)completion;
-(void)show:(UIViewController*)viewController
 completion:(MEOAlertViewShownCompletion)completion;

-(void)remove:(MEOAlertViewRemovedCompletion)completion;

-(void)setAutoRemoving:(BOOL)autoRemoving
 autoRemovedCompletion:(MEOAlertViewRemovedCompletion)autoRemovedCompletion;

-(void)clear;

@end
