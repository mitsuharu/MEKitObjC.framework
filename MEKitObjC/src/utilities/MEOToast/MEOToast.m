//
//  MEOToast.m
//
//  Created by Mitsuharu Emoto on 2016/10/07.
//  Copyright © 2016年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOToast.h"
#import <QuartzCore/QuartzCore.h>


@interface MEOToastLabel : UILabel

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval progress;

@end

@implementation MEOToastLabel

+ (UIEdgeInsets)padding
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (void)dealloc
{
    [self stopTimer];
}

- (void)drawTextInRect:(CGRect)rect
{
    CGRect rect2 = UIEdgeInsetsInsetRect(rect, [MEOToastLabel padding]);
    [super drawTextInRect:rect2];
}

- (CGSize)intrinsicContentSize
{
    UIEdgeInsets padding = [MEOToastLabel padding];
    CGSize size = [super intrinsicContentSize];
    size.height += padding.top + padding.bottom;
    size.width += padding.left + padding.right;
    return size;
}

- (void)startTimer
{
    [self stopTimer];
    self.progress = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(handleTimer:)
                                                userInfo:nil
                                                 repeats:true];
}

- (void)stopTimer
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        self.progress = 0;
    }
}


- (void)handleTimer:(NSTimer*)timer
{
    self.progress += timer.timeInterval;
    
    if (self.progress > 2.0) {
        [self stopTimer];
        [self removeFromSuperviewWithAnimations];
    }

}

- (void)removeFromSuperviewWithAnimations
{
    if (self && self.superview) {
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.alpha = 0.01;
                         }
                         completion:^(BOOL finished) {
                             [self removeFromSuperview];
                         }];
    }
}

@end


@interface MEOToast ()

@property (nonatomic, retain) MEOToastLabel *label;
@property (nonatomic, retain) NSString *text;

@end

@implementation MEOToast

+ (id)defaultToast
{
    static MEOToast *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[MEOToast alloc] init];
    });
    return obj;
}

+ (void)showText:(NSString*)text
{
    MEOToast *toast = [MEOToast defaultToast];
    [toast showText:text];
}

- (instancetype)init
{
    if (self = [super init]) {
        self.label = nil;
        self.text = nil;
    }
    return self;
}

- (void)dealloc
{
    self.text = nil;
    if (self.label) {
        [self.label stopTimer];
        if (self.label.superview) {
            [self.label removeFromSuperview];
        }
        self.label = nil;
    }
}

- (void)showText:(NSString*)text
{
    _text = text;
    
    if (self.label) {
        if (self.label.superview) {
            [self.label stopTimer];
            [self.label removeFromSuperview];
        }
        self.label = nil;
    }

    if (text == nil || text.length == 0) {
        return;
    }

    CGFloat scale = 0.8;
    UIEdgeInsets padding = [MEOToastLabel padding];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    UIFont *font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    CGFloat height = padding.top + padding.bottom;
    CGFloat width = text.length*font.pointSize + padding.left + padding.right;
    if (screenSize.width * scale < width) {
        width = screenSize.width * scale;
    }

    NSDictionary *attributeDict = @{NSFontAttributeName:font};
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine;
    
    NSArray *textArray = [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString *str in textArray) {
        CGRect rect = [str boundingRectWithSize:CGSizeMake(width - (padding.left + padding.right),
                                                           CGFLOAT_MAX)
                                        options:options
                                     attributes:attributeDict
                                        context:nil];
        height += CGRectGetHeight(rect);
    }
    
    CGRect rect = CGRectMake((screenSize.width - width)/2,
                             screenSize.height - height - 30,
                             width,
                             height);
    self.label = [[MEOToastLabel alloc] initWithFrame:rect];
    self.label.numberOfLines = 0;
    self.label.text = text;
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    self.label.textColor = [UIColor whiteColor];
    self.label.backgroundColor = [UIColor darkGrayColor];
    self.label.clipsToBounds = true;
    self.label.layer.cornerRadius = 5;
    self.label.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.label.layer.borderWidth = 1;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:self.label];
    
    [self.label startTimer];

}


@end
