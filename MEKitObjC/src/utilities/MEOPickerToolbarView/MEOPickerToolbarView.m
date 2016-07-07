//
//  MEOPickerToolbarView.m
//
//  Created by Mitsuharu Emoto on 2015/08/20.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOPickerToolbarView.h"

#define RGB(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]


@interface MEOPickerToolbarView ()
<
    UIPickerViewDataSource,
    UIPickerViewDelegate
>

@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) UIButton *backgroundButton;
@property (nonatomic, retain) UILabel *titleLabel;

@property (nonatomic, retain) UIButton *cancelBtn;
@property (nonatomic, retain) UIButton *doneBtn;


@end


@implementation MEOPickerToolbarView


- (instancetype)init
{
    return [self initWithDelegate:nil];
}

- (instancetype)initWithDelegate:(id<MEOPickerToolbarViewDelegate>)delegate
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    self = [super init];
    if (self) {
        
        self.delegate = delegate;
        self.selectedIndex = 0;
        self.cancelTitle = NSLocalizedString(@"Cancel", @"Cancel");
        self.doneTitle = NSLocalizedString(@"Done", @"Done");
        
        CGRect btnRect = CGRectMake(0, 0, 100, 44);
        UIColor *btnColorNormal = RGB(0, 162, 243);
        UIColor *btnColorHighlighted = [UIColor grayColor];
        
        self.cancelBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        self.cancelBtn.frame = btnRect;
        self.cancelBtn.exclusiveTouch = true;
        self.cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.cancelBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:[UIFont buttonFontSize]]];
        [self.cancelBtn setTitle:self.cancelTitle
                   forState:(UIControlStateNormal)];
        [self.cancelBtn setTitleColor:btnColorNormal
                        forState:UIControlStateNormal];
        [self.cancelBtn setTitleColor:btnColorHighlighted
                        forState:UIControlStateHighlighted];
        [self.cancelBtn addTarget:self
                      action:@selector(toolbarDidCancel:)
            forControlEvents:(UIControlEventTouchUpInside)];
        
        self.doneBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        self.doneBtn.frame = btnRect;
        self.doneBtn.exclusiveTouch = true;
        self.doneBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.doneBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:[UIFont buttonFontSize]]];
        [self.doneBtn setTitle:self.doneTitle
                   forState:(UIControlStateNormal)];
        [self.doneBtn setTitleColor:btnColorNormal
                      forState:UIControlStateNormal];
        [self.doneBtn setTitleColor:btnColorHighlighted
                      forState:UIControlStateHighlighted];
        [self.doneBtn addTarget:self
                      action:@selector(toolbarDidEnter:)
            forControlEvents:(UIControlEventTouchUpInside)];
        

        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:self.cancelBtn];
        UIBarButtonItem *enterItem = [[UIBarButtonItem alloc] initWithCustomView:self.doneBtn];
        
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                   target:nil action:nil];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.adjustsFontSizeToFitWidth = true;
        _titleLabel.minimumScaleFactor = 0.5;
        UIBarButtonItem *titleItem = [[UIBarButtonItem alloc] initWithCustomView:_titleLabel];
        
        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(screenRect), 44)];
        UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
        fixedSpace.width = 10;
        _toolbar.items = @[fixedSpace, cancelItem, spacer, titleItem, spacer, enterItem, fixedSpace];

        _pickerView = [[UIPickerView alloc] init];
        _pickerView.showsSelectionIndicator = true;
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        
        CGRect pRect = _pickerView.frame;
        pRect.origin.y = 44;
        pRect.size.width = CGRectGetWidth(screenRect);
        _pickerView.frame = pRect;

        
        self.backgroundColor = [UIColor whiteColor];
        self.frame = CGRectMake(0, 0,
                                CGRectGetWidth(screenRect),
                                CGRectGetHeight(_toolbar.frame) + CGRectGetHeight(_pickerView.frame));
        
        [self addSubview:_toolbar];
        [self addSubview:_pickerView];
        
    }
    return self;
}

#pragma mark - IO

- (void)setTitle:(NSString *)title
{
    _title = title;
    if (self.titleLabel) {
        self.titleLabel.text = title;
    }
}

- (void)setCancelTitle:(NSString *)cancelTitle
{
    _cancelTitle = cancelTitle;
    if (self.cancelBtn) {
        [self.cancelBtn setTitle:_cancelTitle
                        forState:(UIControlStateNormal)];
    }
}

- (void)setDoneTitle:(NSString *)doneTitle
{
    _doneTitle = doneTitle;
    if (self.doneBtn) {
        [self.doneBtn setTitle:_doneTitle
                      forState:(UIControlStateNormal)];
    }
}

#pragma mark - show

- (void)showAnimated:(BOOL)animated
{
    if (self.superview) {
        [self removeAnimated:false];
    }
    
    static BOOL isAnimating = false;
    if (isAnimating) {
        return;
    }
    isAnimating = true;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect rect0 = self.frame;
    CGRect rect1 = self.frame;
    
    rect0.origin.y = CGRectGetHeight(screenRect);
    rect1.origin.y = CGRectGetHeight(screenRect)-CGRectGetHeight(rect1);
    
    self.frame = rect0;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    self.backgroundButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.backgroundButton.frame = [[UIScreen mainScreen] bounds];
    self.backgroundButton.backgroundColor = RGBA(50, 50, 50, 0.5);
    [self.backgroundButton addTarget:self
                            action:@selector(doBackgroundButton:)
                  forControlEvents:(UIControlEventTouchUpInside)];
    [window addSubview:self.backgroundButton];
    
    [window addSubview:self];
    
    [self.pickerView selectRow:self.selectedIndex
                   inComponent:0
                      animated:false];
    
    NSTimeInterval interval = 0.0;
    if (animated) {
        interval = 0.3;
    }
    
    [UIView animateWithDuration:interval
                     animations:^{
                         self.frame = rect1;
                     } completion:^(BOOL finished) {
                         isAnimating = false;
                     }];
}


- (void)removeAnimated:(BOOL)animated
{
    static BOOL isAnimating = false;
    if (isAnimating) {
        return;
    }
    isAnimating = true;
    
    NSTimeInterval interval = 0.0;
    if (animated) {
        interval = 0.4;
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect rect = self.frame;
    rect.origin.y = CGRectGetHeight(screenRect);
    
    if (self.backgroundButton) {
        [self.backgroundButton removeFromSuperview];
        self.backgroundButton = nil;
    }
    
    [UIView animateWithDuration:interval
                     animations:^{
                         self.frame = rect;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         isAnimating = false;
                     }];
}

#pragma mark - イベント

- (void)toolbarDidCancel:(id)sender
{
    [self removeAnimated:true];
    
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(pickerToolbarViewDidCancel:)]) {
        [self.delegate pickerToolbarViewDidCancel:self];
    }
    
}

- (void)toolbarDidEnter:(id)sender
{
    [self removeAnimated:true];

    if (self.delegate
        && [self.delegate respondsToSelector:@selector(pickerToolbarViewDidDone:)]) {
        [self.delegate pickerToolbarViewDidDone:self];
    }
    
}

- (void)doBackgroundButton:(id)sender
{
    [self toolbarDidCancel:nil];
}


#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    NSInteger rows = 0;
    
    if (self.dataSource && self.dataSource.count > 0) {
        rows = self.dataSource.count;        
    }
    
    return rows;
}

#pragma mark UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView
rowHeightForComponent:(NSInteger)component
{
    //    CGSize size = [pickerView rowSizeForComponent:component];
    return 50;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = nil;
    
    if (row < self.dataSource.count) {
        title = [self.dataSource objectAtIndex:row];
    }
    
    return title;
}


- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    self.selectedIndex = row;
}



@end
