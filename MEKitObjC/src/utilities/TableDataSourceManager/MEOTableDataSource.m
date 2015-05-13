//
//  MEOTableDataSource.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/10/17.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOTableDataSource.h"

@interface MEOTableDataSource ()
{
    NSMutableArray *dataSource_;
    NSMutableArray *detailSource_;
    NSString *headerString_;
    NSString *footerString_;
    NSInteger tag_;
    
    NSMutableArray *cellIdentifiers_;
    NSMutableArray *cellHeights_;
}

@end

@implementation MEOTableDataSource

@synthesize dataSource = dataSource_;
@synthesize detailSource = detailSource_;
@synthesize headerString = headerString_;
@synthesize footerString = footerString_;
@synthesize tag = tag_;
@synthesize cellIdentifiers = cellIdentifiers_;
@synthesize cellHeights = cellHeights_;



@end
