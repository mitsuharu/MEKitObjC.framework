//
//  ActivityHelper.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/11/29.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "MEOLINEActivity.h"
#import "MEOInstagramActivity.h"

typedef id (^AHItemBlock)(UIActivityViewController* activityViewController, NSString* activityType);
typedef id (^AHPhItemBlock)(UIActivityViewController* activityViewController);


@interface MEOActivityHelper : NSObject

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSURL *url;

-(id)initWithItemBlock:(AHItemBlock)itemBlock
           phItemBlock:(AHPhItemBlock)phItemBlock;


/**
 *  シェアデータからアクティビティコントローラを生成する
 *
 *  @code
 UIActivityViewController *vc = nil;
 vc = [MEOActivityHelper activityViewControllerWithText:...];
 [self presentViewController:vc animated:true completion:^{}];
 *  @endcode
 *
 *  @return アクティビティコントローラ
 */
+ (UIActivityViewController *)activityViewControllerWithText:(NSString*)text
                                                   urlString:(NSString*)urlString
                                                       image:(UIImage*)image;

+ (NSArray *)excludedActivityTypes;

@end
