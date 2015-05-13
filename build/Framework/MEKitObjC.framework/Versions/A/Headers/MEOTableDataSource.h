//
//  MEOTableDataSource.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/10/17.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MEOTableDataSource : NSObject

@property (nonatomic, retain) NSMutableArray *dataSource;
@property (nonatomic, retain) NSMutableArray *detailSource;
@property (nonatomic, retain) NSMutableArray *cellIdentifiers;
@property (nonatomic, retain) NSMutableArray *cellHeights;
@property (nonatomic, retain) NSString *headerString;
@property (nonatomic, retain) NSString *footerString;
@property (nonatomic) NSInteger tag;

@end
