//
//  MEOTableViewCell.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2014/11/05.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOTableViewCell.h"

@interface MEOTableViewCell ()
{
    UITextField *textField_;
    UITextView *textView_;
    UILabel *textLabel_;
    UIImageView *imageView_;
}

@end

@implementation MEOTableViewCell

@synthesize textField = textField_;
@synthesize textView = textView_;
@synthesize textLabel = textLabel_;
@synthesize imageView = imageView_;


-(void)clear
{
    if (textLabel_) {
        textLabel_.text = nil;
    }
    if (textField_) {
        textField_.text = nil;
    }
    if (textView_) {
        textView_.text = nil;
    }
    if (imageView_) {
        imageView_.image = nil;
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
