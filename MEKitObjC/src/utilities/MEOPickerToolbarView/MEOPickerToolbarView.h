//
//  MEOPickerToolbarView.h
//
//  Created by Mitsuharu Emoto on 2015/08/20.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MEOPickerToolbarView;

@protocol MEOPickerToolbarViewDelegate <NSObject>

@optional


- (CGFloat)meoPickerToolbarView:(MEOPickerToolbarView*)pickerToolbarView
                     pickerView:(UIPickerView *)pickerView
          rowHeightForComponent:(NSInteger)component;


-(void)meoPickerToolbarViewDidCancel:(MEOPickerToolbarView*)pickerToolbarView;
-(void)meoPickerToolbarViewDidDone:(MEOPickerToolbarView*)pickerToolbarView;

@end

/**
 *  決定・キャンセルボタン付きのピッカービュー
 */
@interface MEOPickerToolbarView : UIView

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, retain) NSMutableArray *dataSource;
@property (nonatomic, weak) id<MEOPickerToolbarViewDelegate> delegate;

// 任意設定
@property (nonatomic, retain, readonly) UIPickerView *pickerView;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *cancelTitle;
@property (nonatomic, retain) NSString *doneTitle;


- (instancetype)initWithDelegate:(id<MEOPickerToolbarViewDelegate>)delegate;

- (void)showAnimated:(BOOL)animated;
- (void)removeAnimated:(BOOL)animated;

@end
