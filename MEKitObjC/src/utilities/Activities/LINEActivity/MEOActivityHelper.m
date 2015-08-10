//
//  ActivityHelper.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/11/29.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOActivityHelper.h"

@interface MEOActivityHelper () < UIActivityItemSource >
{
    AHItemBlock itemBlock_;
    AHPhItemBlock phItemBlock_;
    
    NSString *text_;
    NSURL *url_;
}

@end

@implementation MEOActivityHelper

@synthesize text = text_;
@synthesize url = url_;

-(id)initWithItemBlock:(AHItemBlock)itemBlock
           phItemBlock:(AHPhItemBlock)phItemBlock
{
    if (self = [super init]) {
        itemBlock_ = [itemBlock copy];
        phItemBlock_ = [phItemBlock copy];
    }
    return self;
}


#pragma mark - UIActivityItemSource

-(id)activityViewController:(UIActivityViewController *)activityViewController
        itemForActivityType:(NSString *)activityType
{
    // Twitterの時だけハッシュタグをつける
    // DLog(@"%@", activityType);
    
    if (itemBlock_) {
        return itemBlock_(activityViewController, activityType);
    }
    
    id resultl = text_;
    if ([activityType isEqualToString:ActivityTypeLINE]) {
        NSString *str = [NSString stringWithFormat:@"%@ %@", text_, url_.absoluteString];
        // DLog(@"%@", str);
        return str;
    }
    return resultl;
}

-(id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    if (phItemBlock_) {
        return phItemBlock_(activityViewController);
    }
    
    return text_;
}

#pragma mark - UIActivityViewController

+(UIActivityViewController*)activityViewControllerWithText:(NSString*)text
                                                 urlString:(NSString*)urlString
                                                     image:(UIImage*)image
{
    MEOActivityHelper *achpText = [[MEOActivityHelper alloc] initWithItemBlock:^id(UIActivityViewController *activityViewController,
                                                                                   NSString *activityType)
    {
        if ([activityType isEqualToString:ActivityTypeLINE]) {
            NSString *str = [NSString stringWithFormat:@"%@ %@", text, urlString];
            return str;
        }
        return text;
    } phItemBlock:^id(UIActivityViewController *activityViewController) {
        return text;
    }];
    
    
    MEOActivityHelper *achpUrl = [[MEOActivityHelper alloc] initWithItemBlock:^id(UIActivityViewController *activityViewController,
                                                                                  NSString *activityType)
    {
        //        if ([activityType isEqualToString:UIActivityTypeMail] || [activityType isEqualToString:UIActivityTypeMessage]) {
        //            if (isGa) {
        //                urlStr2 = [[NSString alloc] initWithFormat:@"%@?utm_medium=email&utm_source=ios",urlStr2];
        //            }
        //        }else if ([activityType isEqualToString:UIActivityTypePostToTwitter]){
        //            if (isGa) {
        //                urlStr2 = [[NSString alloc] initWithFormat:@"%@?utm_medium=social&utm_source=twitter&utm_campaign=ios",urlStr2];
        //            }
        //        }else if ([activityType isEqualToString:UIActivityTypePostToFacebook]){
        //            if (isGa) {
        //                urlStr2 = [[NSString alloc] initWithFormat:@"%@?utm_medium=social&utm_source=facebook&utm_campaign=ios",urlStr2];
        //            }
        //        }else if ([activityType isEqualToString:ActivityTypeLINE]) {
        //            if (isGa) {
        //                urlStr2 = [[NSString alloc] initWithFormat:@"%@?utm_medium=social&utm_source=line&utm_campaign=ios",urlStr2];
        //            }
        //        }
        
        return [NSURL URLWithString:urlString];
        
        
    } phItemBlock:^id(UIActivityViewController *activityViewController) {
        return [NSURL URLWithString:urlString];
    }];
    
    MEOActivityHelper *achpImage = [[MEOActivityHelper alloc] initWithItemBlock:^id(UIActivityViewController *activityViewController,
                                                                                  NSString *activityType)
    {
        return image;
    } phItemBlock:^id(UIActivityViewController *activityViewController) {
        return image;
    }];
    
    NSMutableArray* items = [NSMutableArray arrayWithObjects:achpText, achpUrl, achpImage, nil];
    
    float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    NSString *lineScheme = @"line:";
    NSMutableArray *activities = nil;
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:lineScheme]]
        && iOSVersion < 8.0) {
        
        if (activities == nil) {
            activities = [[NSMutableArray alloc] initWithCapacity:1];
        }
        
        LINEActivity *act = [[LINEActivity alloc] init];
        [activities addObject:act];
    }
    

    UIActivityViewController *activityViewController = nil;
    activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items
                                                                applicationActivities:activities];
//    activityViewController.completionHandler = ^(NSString *activityType, BOOL completed)
//    {
//        if (completed || [activityType isEqualToString:@"jp.naver.LINEActivity"]) {
//        }
//    };
    
//    NSArray *excludedActivityTypes = @[UIActivityTypeAddToReadingList,
//                                       UIActivityTypeAirDrop,
//                                       UIActivityTypeCopyToPasteboard,
//                                       UIActivityTypePostToFlickr,
//                                       UIActivityTypePostToTencentWeibo,
//                                       UIActivityTypePostToVimeo,
//                                       UIActivityTypePostToWeibo,
//                                       UIActivityTypePrint,
//                                       UIActivityTypeSaveToCameraRoll,
//                                       UIActivityTypeAssignToContact];
//    activityViewController_.excludedActivityTypes = excludedActivityTypes;

    return activityViewController;
}

+ (NSArray * )excludedActivityTypes
{
    NSArray *excludedActivityTypes = @[UIActivityTypeAddToReadingList,
                                       UIActivityTypeAirDrop,
                                       UIActivityTypeCopyToPasteboard,
                                       UIActivityTypePostToFlickr,
                                       UIActivityTypePostToTencentWeibo,
                                       UIActivityTypePostToVimeo,
                                       UIActivityTypePostToWeibo,
                                       UIActivityTypePrint,
                                       UIActivityTypeSaveToCameraRoll,
                                       UIActivityTypeAssignToContact];
    return excludedActivityTypes;
}

@end
