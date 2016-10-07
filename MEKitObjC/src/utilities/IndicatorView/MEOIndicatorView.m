//
//  MEOIndicatorView.m
//  MEKitObjC
//
//  Created by mitsuharu on 10/04/21.
//  Copyright 2010 Mitsuharu Emoto. All rights reserved.
//

#import "MEOIndicatorView.h"
#import <QuartzCore/QuartzCore.h>

#if !defined(MIN)
#define MIN(A,B)	({ __typeof__(A) __a = (A); __typeof__(B) __b = (B); __a < __b ? __a : __b; })
#endif

#define BLANLVIEW_ALPHA 0.1f
#define BLANLVIEW_COLOR [UIColor blackColor]

@interface MEOIndicatorView ()
{
	UIActivityIndicatorView *indicator_;
	UILabel *textLabel_;
    UIButton *cancelButton_;
    
    UIView *blankView_;
    BOOL isVisible_;
    BOOL enableTapEvents_;
    id<MEOIndicatorViewDelegate> delegate_;
}

+(id)defaultIndicatorView;

@end

@implementation MEOIndicatorView

@synthesize delegate = delegate_;
@synthesize isVisible = isVisible_;
@synthesize enableTapEvents = enableTapEvents_;

+(id)defaultIndicatorView
{
    static MEOIndicatorView *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[MEOIndicatorView alloc] init];
    });
    return singleton;
}

+(void)show
{
    [MEOIndicatorView show:nil tapEvent:NO];
}

+(void)show:(NSString*)title
{
    [MEOIndicatorView show:title tapEvent:NO];
}

+(void)show:(NSString*)text tapEvent:(BOOL)enable
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MEOIndicatorView *iv = [MEOIndicatorView defaultIndicatorView];
        if (iv && iv.isVisible == false) {
            [iv setText:text];
            [iv show:enable];
        }
    });
}

+(void)setText:(NSString*)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MEOIndicatorView *iv = [MEOIndicatorView defaultIndicatorView];
        if (iv) {
            [iv setText:text];
        }
    });
}


+(void)remove
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MEOIndicatorView *iv = [MEOIndicatorView defaultIndicatorView];
        if (iv) {
            [iv remove];
        }
    });
}


-(id)init
{
    CGFloat length = 140;
    CGRect rect = CGRectMake(0, 0, length, length);
    
	if ( (self = [super initWithFrame:rect] ) )
	{
        isVisible_ = NO;
        
		// 背景色の初期化
		self.backgroundColor = [UIColor blackColor];

		// 各を丸くする
		self.layer.cornerRadius = 10;
		self.clipsToBounds = true;
		
		// インディケータの大きさ
		CGFloat indicatorSize = MIN(self.frame.size.width, self.frame.size.height)*0.3;
		
		// インディケータ
		indicator_ = [[UIActivityIndicatorView alloc] init];
        indicator_.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2, 2);        
		[indicator_ setHidesWhenStopped:YES];
		[indicator_  setFrame:CGRectMake(self.frame.size.width/2.0-indicatorSize/2.0,
										self.frame.size.height/2.0-indicatorSize/2.0,
										indicatorSize, 
										indicatorSize)];
		[indicator_ startAnimating];
		[self addSubview:indicator_];
		
		// 注釈ラベル
        
        CGFloat scale = 0.8;
		textLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width*(1.0-scale)/2.0,
															  indicator_.frame.origin.y + indicator_.frame.size.height,
															  self.frame.size.width*scale,
															  self.frame.size.height - (indicator_.frame.origin.y + indicator_.frame.size.height))];
		//textLabel_.text = @"now login...";
		textLabel_.textColor = [UIColor whiteColor];
		textLabel_.backgroundColor = [UIColor clearColor];
        textLabel_.adjustsFontSizeToFitWidth = YES;
        textLabel_.minimumScaleFactor = 0.2;
        textLabel_.textAlignment = NSTextAlignmentCenter;
        textLabel_.adjustsFontSizeToFitWidth = YES;
        
		[self addSubview:textLabel_];
	}
		
	return self;
}

- (void)dealloc 
{
	indicator_ = nil;
    textLabel_ = nil;
    if (isVisible_) {
        [self remove];
    }
}

-(void)setText:(NSString *)text
{
	textLabel_.text = text;
}

-(void)setCancelTitle:(NSString *)cancelTitle
{
    // キャンセルボタン
    if(!cancelButton_) {
        cancelButton_ = [UIButton buttonWithType:UIButtonTypeSystem];
        [cancelButton_ setTitleColor:[UIColor whiteColor]
                            forState:UIControlStateNormal];
        cancelButton_.backgroundColor = self.backgroundColor;
        cancelButton_.layer.cornerRadius = 10;
		cancelButton_.clipsToBounds = true;
        [cancelButton_ addTarget:self
                          action:@selector(cancelTouchUpInside:)
                forControlEvents:UIControlEventTouchUpInside];

        
        [self.window addSubview:cancelButton_];
    }

    if(cancelTitle && 0 < [cancelTitle length]) {
        [cancelButton_ setTitle:cancelTitle forState:UIControlStateNormal];
        [cancelButton_ sizeToFit];

        CGRect buttonFrame = self.frame;
        buttonFrame.origin.y = CGRectGetMaxY(self.frame) + 10;
        buttonFrame.size.height = CGRectGetHeight(cancelButton_.frame);

        cancelButton_.frame = buttonFrame;
        
        cancelButton_.hidden = NO;
    }
    else {
        cancelButton_.hidden = YES;
    }
}

-(void)show
{
    [self show:NO];
}

-(void)show:(BOOL)enableTapEvents
{
    if (isVisible_) {
        return;
    }
    
    enableTapEvents_ = enableTapEvents;
    
    isVisible_ = YES;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    if (!enableTapEvents) {
        blankView_ = [[UIView alloc] initWithFrame:window.frame];
        [blankView_ setAlpha:BLANLVIEW_ALPHA];
        [blankView_ setBackgroundColor:BLANLVIEW_COLOR];
        [window addSubview:blankView_];        
    }
    
    [window addSubview:self];
    
    CGSize size = window.frame.size;
    self.center = CGPointMake(size.width/2, size.height/2);
  
    
    if (delegate_ && [delegate_ respondsToSelector:@selector(indicatorViewShown:)]) {
        [delegate_ indicatorViewShown:self];
    }
    
    
    // キーボードの通知を開始する
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self
                     selector:@selector(keyboardWillShow:)
						 name:UIKeyboardDidShowNotification
                       object:nil];
    [notification addObserver:self
                     selector:@selector(keyboardWillHide:)
                         name:UIKeyboardWillHideNotification
                       object:nil];
    
}


-(void)remove
{
    if (isVisible_ == NO) {
        return;
    }
    
    isVisible_ = NO;
    
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [notification removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
    if (blankView_) {
        [blankView_ removeFromSuperview];
        blankView_ = nil;
    }
    
    if (self.superview) {
        [self removeFromSuperview];
    }
    
    if (delegate_ && [delegate_ respondsToSelector:@selector(indicatorViewRemoved:)]) {
        [delegate_ indicatorViewRemoved:self];
    }
}

#pragma mark - actions
- (void)cancelTouchUpInside:(id)sender
{
    // call delegate
    if (delegate_ && [delegate_ respondsToSelector:@selector(indicatorViewDidCancel:)]) {
        [delegate_ indicatorViewDidCancel:self];
    }
}

#pragma mark - キーボード通知

-(void)keyboardWillShow:(NSNotification*)notification
{
    if (blankView_) {
        [self.superview bringSubviewToFront:blankView_];
    }
    [self.superview bringSubviewToFront:self];
}

-(void)keyboardWillHide:(NSNotification*)notification
{
}

@end
