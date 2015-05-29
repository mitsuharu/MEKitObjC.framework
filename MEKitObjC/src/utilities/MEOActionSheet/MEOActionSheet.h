//
//  MEOActionSheet.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/04/03.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MEOActionSheet;

typedef void (^MEOActionSheetCompletion)(MEOActionSheet *actionSheet, NSInteger buttonIndex);
typedef void (^MEOActionSheetShownCompletion)();

@interface MEOActionSheet : NSObject

@property (nonatomic) NSInteger tag;
@property (nonatomic, retain, readonly) NSMutableArray *buttonTitles;
@property (nonatomic, readonly) NSInteger cancelButtonIndex;
@property (nonatomic, readonly) NSInteger destructiveButtonIndex;
@property (nonatomic, readonly) BOOL isShowing;
@property (nonatomic) BOOL autoRemoving;

-(id)initWithTitle:(NSString *)title
           message:(NSString *)message
        completion:(MEOActionSheetCompletion)completion
 cancelButtonTitle:(NSString *)cancelButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
 otherButtonTitles:(NSString *)otherButtonTitles, ...;

-(void)show:(MEOActionSheetShownCompletion)completion;
-(void)show:(UIViewController*)viewController
 completion:(MEOActionSheetShownCompletion)completion;

-(void)remove:(MEOActionSheetShownCompletion)completion;

-(void)clear;

@end
