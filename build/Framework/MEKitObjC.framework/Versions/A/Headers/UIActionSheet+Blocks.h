//
//  UIActionSheet+Blocks.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/01/22.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActionSheet (Blocks) <UIActionSheetDelegate>

typedef void (^ActionSheetCompletion)(UIActionSheet *actionSheet, NSInteger buttonIndex);

-(id)initWithTitle:(NSString *)title
        completion:(ActionSheetCompletion)completion
 cancelButtonTitle:(NSString *)cancelButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
 otherButtonTitles:(NSString *)otherButtonTitles, ...;


-(void)setCompletion:(ActionSheetCompletion)completion;

@end
