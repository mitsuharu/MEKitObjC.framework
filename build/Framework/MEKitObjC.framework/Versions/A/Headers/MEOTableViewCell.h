//
//  MEOTableViewCell.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2014/11/05.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MEOTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UITextField *textField;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UILabel *textLabel;

-(void)clear;

@end
