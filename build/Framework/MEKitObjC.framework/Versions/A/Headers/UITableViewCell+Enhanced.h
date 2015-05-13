//
//  UITableViewCell+Enhanced.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/12/25.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UITableViewCellSwitchHandler)(UITableViewCell *cell, UISwitch *sw);
typedef void (^UITableViewCellSegmentedControlHandler)(UITableViewCell *cell, UISegmentedControl *sgControl);
typedef void (^UITableViewCellButtonHandler)(UITableViewCell *cell, UIButton *button);

typedef void (^UITableViewCellTextFieldHandler)(UITableViewCell *cell, UITextField *textField);
typedef void (^UITableViewCellViewHandler)(UITableViewCell *cell, UIView *view);


@protocol UITableViewCellAccessoryViewDelegate <NSObject>
@optional
-(void)tableViewCell:(UITableViewCell*)cell didSwitch:(UISwitch*)sw;
-(void)tableViewCell:(UITableViewCell*)cell didSegmentedControl:(UISegmentedControl*)sgControl;
-(void)tableViewCell:(UITableViewCell*)cell didButton:(UIButton*)button;
@end


@interface UITableViewCell (Enhanced)


-(void)removeAccessoryViews;

-(void)setAccessoryViewDelegate:(id<UITableViewCellAccessoryViewDelegate>)delegate;

-(void)addSwitch:(BOOL)on handler:(UITableViewCellSwitchHandler)switchHandler;
-(void)removeSwitch;

-(void)addSegmentedControl:(NSArray*)titles
             selectedIndex:(NSInteger)selectedIndex
                   handler:(UITableViewCellSegmentedControlHandler)switchHandler;
-(void)removeSegmentedControl;

-(void)addButton:(NSString*)title handler:(UITableViewCellButtonHandler)handler;
-(void)removeButton;


-(void)removeContentViews;
-(void)addView:(UIView*)view handler:(UITableViewCellViewHandler)handler;

-(UITextField*)textField;
-(void)addTextField:(UITableViewCellTextFieldHandler)handler;
-(void)removeTextField;



@end
