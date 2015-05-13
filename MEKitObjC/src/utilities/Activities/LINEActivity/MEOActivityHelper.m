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

@end
