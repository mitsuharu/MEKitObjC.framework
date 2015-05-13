//
//  UIAlertView+Blocks.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/01/22.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Blocks) <UIAlertViewDelegate>

typedef void (^AlertViewCompletion)(UIAlertView *alertView, NSInteger buttonIndex);

-(id)initWithTitle:(NSString *)title
           message:(NSString *)message
        completion:(AlertViewCompletion)completion
 cancelButtonTitle:(NSString *)cancelButtonTitle
 otherButtonTitles:(NSString *)otherButtonTitles, ...;


@end
