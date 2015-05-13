//
//  MEONotificationWindow.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2014/12/17.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^MEONotificationCompletion)(void);

@interface MEONotificationWindow : UIWindow

+(void)showWithTitle:(NSString*)title
            messsage:(NSString*)messsage
                icon:(UIImage*)icon
             touched:(MEONotificationCompletion)touched
          allowQueue:(BOOL)allowQueue;

+(void)showWithTitle:(NSString*)title
            messsage:(NSString*)messsage
                icon:(UIImage*)icon
             touched:(MEONotificationCompletion)touched;
+(void)remove;
+(BOOL)isVisible;

@end
