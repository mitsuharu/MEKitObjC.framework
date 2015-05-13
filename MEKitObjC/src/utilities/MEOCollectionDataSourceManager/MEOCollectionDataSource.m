//
//  MEOCollectionDataSource.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/04/01.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOCollectionDataSource.h"

@implementation MEOCollectionDataSource

-(id)init
{
    if (self = [super init]) {
        self.dataSource = nil;
        self.detailSource = nil;
        self.headerString = nil;
        self.footerString = nil;
        self.cellIdentifiers = nil;
        self.cellHeights = nil;
        self.tag = 0;
    }
    return self;
}

@end
