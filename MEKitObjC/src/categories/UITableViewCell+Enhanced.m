//
//  UITableViewCell+Enhanced.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/12/25.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import "UITableViewCell+Enhanced.h"
#import <objc/runtime.h>

#define KEY_AccessoryViewDelegate @"KEY_AccessoryViewDelegate"
#define KEY_SwitchHandler @"KEY_SwitchHandler"
#define KEY_SegmentedControlHandler @"KEY_SegmentedControlHandler"
#define KEY_ButtonHandler @"KEY_ButtonHandler"


UInt8 kTagTextfield = 0;

@implementation UITableViewCell (Enhanced)

// MARK: - AccessoryViews

-(void)removeAccessoryViews
{
    [self removeSwitch];
    [self removeSegmentedControl];
    [self removeButton];
    self.accessoryView = nil;
}

-(void)setAccessoryViewDelegate:(id<UITableViewCellAccessoryViewDelegate>)delegate
{
    objc_setAssociatedObject(self,
                             KEY_AccessoryViewDelegate,
                             delegate,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// MARK: - Switch

-(void)addSwitch:(BOOL)on handler:(UITableViewCellSwitchHandler)switchHandler
{
    UISwitch *sw = [[UISwitch alloc] init];
    sw.on = on;
    [sw addTarget:self
           action:@selector(doSwitch:)
 forControlEvents:(UIControlEventValueChanged)];
 
    objc_setAssociatedObject(self,
                             KEY_SwitchHandler,
                             [switchHandler copy],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    self.accessoryView = sw;
}

-(void)removeSwitch
{
    objc_setAssociatedObject(self,
                             KEY_SwitchHandler,
                             nil,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.accessoryView = nil;
}

-(void)doSwitch:(id)sender
{
    UISwitch *sw = nil;
    if ([self.accessoryView isKindOfClass:[UISwitch class]]) {
        sw = (UISwitch*)(self.accessoryView);
    }
    
    if (sw) {
        id<UITableViewCellAccessoryViewDelegate> delegate = nil;
        delegate = objc_getAssociatedObject(self, KEY_AccessoryViewDelegate);
        if (delegate && [delegate respondsToSelector:@selector(tableViewCell:didSwitch:)]) {
            [delegate tableViewCell:self didSwitch:sw];
        }
        UITableViewCellSwitchHandler handler = nil;
        handler = objc_getAssociatedObject(self, KEY_SwitchHandler);
        if (handler) {
            handler(self, sw);
        }
    }
}

// MARK: - SegmentedControl

-(void)addSegmentedControl:(NSArray*)titles
             selectedIndex:(NSInteger)selectedIndex
                   handler:(UITableViewCellSegmentedControlHandler)switchHandler
{
    UISegmentedControl *sg = [[UISegmentedControl alloc] initWithItems:titles];
    sg.selectedSegmentIndex = selectedIndex;
    [sg addTarget:self
           action:@selector(doSegmentedControl:)
 forControlEvents:(UIControlEventValueChanged)];
    
    objc_setAssociatedObject(self,
                             KEY_SegmentedControlHandler,
                             [switchHandler copy],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.accessoryView = sg;
}

-(void)removeSegmentedControl
{
    objc_setAssociatedObject(self,
                             KEY_SegmentedControlHandler,
                             nil,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.accessoryView = nil;
}

-(void)doSegmentedControl:(id)sender
{
    UISegmentedControl *sg = nil;
    if ([self.accessoryView isKindOfClass:[UISegmentedControl class]]) {
        sg = (UISegmentedControl*)(self.accessoryView);
    }
    
    if (sg) {
        id<UITableViewCellAccessoryViewDelegate> delegate = nil;
        delegate = objc_getAssociatedObject(self, KEY_AccessoryViewDelegate);
        if (delegate && [delegate respondsToSelector:@selector(tableViewCell:didSegmentedControl:)]) {
            [delegate tableViewCell:self didSegmentedControl:sg];
        }
        UITableViewCellSegmentedControlHandler handler = nil;
        handler = objc_getAssociatedObject(self, KEY_SegmentedControlHandler);
        if (handler) {
            handler(self, sg);
        }
    }
}

// MARK: - buttons

-(void)addButton:(NSString*)title
         handler:(UITableViewCellButtonHandler)handler
{
    UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];

    CGFloat width = btn.titleLabel.font.pointSize * title.length;
    CGRect rect = CGRectMake(0, 0, width, self.frame.size.height);
    [btn setFrame:rect];
        
    [btn setTitle:title forState:(UIControlStateNormal)];
    [btn.titleLabel setTextAlignment:(NSTextAlignmentRight)];
    
    [btn setTitleColor:self.tintColor forState:(UIControlStateNormal)];
    [btn setTitleColor:[UIColor lightTextColor] forState:(UIControlStateHighlighted)];

    [btn addTarget:self
            action:@selector(doButton:)
  forControlEvents:(UIControlEventTouchUpInside)];
    
    objc_setAssociatedObject(self,
                             KEY_ButtonHandler,
                             [handler copy],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.accessoryView = btn;
}

-(void)removeButton
{
    objc_setAssociatedObject(self,
                             KEY_ButtonHandler,
                             nil,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.accessoryView = nil;
}


-(void)doButton:(id)sender
{
    UIButton *btn = nil;
    if ([self.accessoryView isKindOfClass:[UIButton class]]) {
        btn = (UIButton*)(self.accessoryView);
    }
    
    if (btn) {
        id<UITableViewCellAccessoryViewDelegate> delegate = nil;
        delegate = objc_getAssociatedObject(self, KEY_AccessoryViewDelegate);
        if (delegate && [delegate respondsToSelector:@selector(tableViewCell:didButton:)]) {
            [delegate tableViewCell:self didButton:btn];
        }
        UITableViewCellButtonHandler handler = nil;
        handler = objc_getAssociatedObject(self, KEY_ButtonHandler);
        if (handler) {
            handler(self, btn);
        }
    }
}

-(void)removeContentViews
{
    UIView *view = self.contentView;
    if (view == nil) {
        view = self;
    }

    for (UIView *v in view.subviews) {
        [v removeFromSuperview];
    }
}

-(void)addView:(UIView*)view handler:(UITableViewCellViewHandler)handler
{
    UIView *v = self.contentView;
    if (v == nil) {
        v = self;
    }
    
    UIEdgeInsets insets = self.separatorInset;
    CGRect rect = view.frame;
    rect.origin.x = insets.left;
    rect.size.width = rect.size.width - insets.left;
    
    if (self.textLabel) {
        self.textLabel.text = @"";
    }

    view.frame = rect;
    [v addSubview:view];
    
    if (handler){
        handler(self, view);
    }
}

-(UITextField*)textField
{
    UIView *view = self.contentView;
    if (view == nil) {
        view = self;
    }
    
    UITextField *tf = nil;
    for (UIView *v in view.subviews) {
        if ([v isKindOfClass:[UITextField class]]) {
            UITextField *temp = (UITextField*)v;
            if (temp.tag == (NSInteger)(&kTagTextfield)) {
                tf = temp;
                break;
            }
        }
    }
    return tf;
}

-(void)addTextField:(UITableViewCellTextFieldHandler)handler
{
    UIView *view = self.contentView;
    if (view == nil) {
        view = self;
    }
    
    UIEdgeInsets insets = self.separatorInset;
    CGRect rect = view.frame;
    rect.origin.x = insets.left;
    rect.size.width = rect.size.width - insets.left;
    
    if (self.textLabel) {
        self.textLabel.text = @"";
    }
    
    UITextField *tf = [[UITextField alloc] initWithFrame:rect];
    tf.borderStyle = UITextBorderStyleNone;
    tf.backgroundColor = [UIColor clearColor];
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    tf.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tf.tag = (NSInteger)(&kTagTextfield);
    [view addSubview:tf];
    
    if (handler){
        handler(self, tf);
    }
}

-(void)removeTextField
{
    UIView *view = self.contentView;
    if (view == nil) {
        view = self;
    }
    
    for (UIView *v in view.subviews.reverseObjectEnumerator) {
        if ([v isKindOfClass:[UITextField class]]) {
            UITextField *temp = (UITextField*)v;
            if (temp.tag == (NSInteger)(&kTagTextfield)) {
                [temp removeFromSuperview];
                break;
            }
        }
    }
}


@end
