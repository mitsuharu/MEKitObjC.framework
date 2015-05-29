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

-(void)clear
{
    if (dataSource_) {
        [dataSource_ removeAllObjects];
        dataSource_ = nil;
    }
    if (detailSource_) {
        [detailSource_ removeAllObjects];
        detailSource_ = nil;
    }
    if (cellIdentifiers_) {
        [cellIdentifiers_ removeAllObjects];
        cellIdentifiers_ = nil;
    }
    if (cellHeights_) {
        [cellHeights_ removeAllObjects];
        cellHeights_ = nil;
    }
    if (headerString_) {
        headerString_ = nil;
    }
    if (footerString_) {
        footerString_ = nil;
    }
}

@end
