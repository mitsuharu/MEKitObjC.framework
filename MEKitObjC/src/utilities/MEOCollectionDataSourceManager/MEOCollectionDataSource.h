//
//  MEOCollectionDataSource.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/04/01.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MEOCollectionDataSource : NSObject

@property (nonatomic, retain) NSMutableArray *dataSource;
@property (nonatomic, retain) NSMutableArray *detailSource;
@property (nonatomic, retain) NSMutableArray *cellIdentifiers;
@property (nonatomic, retain) NSMutableArray *cellHeights;
@property (nonatomic, retain) NSString *headerString;
@property (nonatomic, retain) NSString *footerString;
@property (nonatomic) NSInteger tag;

@end
