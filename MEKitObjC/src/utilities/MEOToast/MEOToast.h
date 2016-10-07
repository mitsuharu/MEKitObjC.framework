//
//  MEOToast.h
//
//  Created by Mitsuharu Emoto on 2016/10/07.
//  Copyright © 2016年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Toast風に簡易的にテキストを表示する
 */
@interface MEOToast : NSObject

+ (void)showText:(NSString*)text;

@end
