//
//  UITableView+Enhanced.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/03/20.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import "UIScrollView+Enhanced.h"

@implementation UIScrollView (Enhanced)

-(BOOL)isScrollStopped
{
    return (self.dragging == NO && self.decelerating == NO );
}

@end
