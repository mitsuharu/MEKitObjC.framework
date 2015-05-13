//
//  MEOCollectionDataSourceManager.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/04/01.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MEOCollectionDataSource.h"

@class MEOCollectionDataSourceManager;

@protocol MEOCollectionDataSourceManagerDelegate <NSObject>

@required

-(UICollectionViewCell*)collectionDataSourceManager:(MEOCollectionDataSourceManager*)manager
                                     collectionView:(UICollectionView *)collectionView
                             cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

-(UICollectionReusableView*)collectionDataSourceManager:(MEOCollectionDataSourceManager*)manager
                                         collectionView:(UICollectionView *)collectionView
                                  headerViewAtIndexPath:(NSIndexPath *)indexPath;

-(UICollectionReusableView*)collectionDataSourceManager:(MEOCollectionDataSourceManager*)manager
                                         collectionView:(UICollectionView *)collectionView
                                  footerViewAtIndexPath:(NSIndexPath *)indexPath;


- (void)collectionDataSourceManager:(MEOCollectionDataSourceManager*)manager
                     collectionView:(UICollectionView *)collectionView
           didSelectItemAtIndexPath:(NSIndexPath *)indexPath;


/**
 @breif 特定セルのサイズを指定する
 */
- (CGSize)collectionDataSourceManager:(MEOCollectionDataSourceManager*)manager
                       collectionView:(UICollectionView *)collectionView
                               layout:(UICollectionViewLayout *)collectionViewLayout
               sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 @breif ヘッダービューのサイズを指定する
 */
-(CGSize)collectionDataSourceManager:(MEOCollectionDataSourceManager*)manager
                      collectionView:(UICollectionView *)collectionView
                              layout:(UICollectionViewLayout *)collectionViewLayout
     referenceSizeForHeaderInSection:(NSInteger)section;

/**
 @breif フッタービューのサイズを指定する
 */
-(CGSize)collectionDataSourceManager:(MEOCollectionDataSourceManager*)manager
                      collectionView:(UICollectionView *)collectionView
                              layout:(UICollectionViewLayout *)collectionViewLayout
     referenceSizeForFooterInSection:(NSInteger)section;

/**
 @breif スクロールが止まったときに呼ばれる．主に非同期ダウンロードの表示更新などに用いる
 */
-(void)collectionDataSourceManager:(MEOCollectionDataSourceManager*)manager
                    collectionView:(UICollectionView *)collectionView
                  didScrollStopped:(NSArray*)visibleIndexPaths;

@end


@interface MEOCollectionDataSourceManager : NSObject
<
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
>

@property (nonatomic, retain) NSMutableArray *dataSources;
@property (nonatomic, weak) id<MEOCollectionDataSourceManagerDelegate> delegate;

@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, retain) NSString *cellIdentifier;
@property (nonatomic, retain) NSString *headerReuseIdentifier;
@property (nonatomic, retain) NSString *footerReuseIdentifier;


-(id)initWithDelegate:(id<MEOCollectionDataSourceManagerDelegate>)delegate
       collectionView:(UICollectionView*)collectionView
       cellIdentifier:(NSString*)cellIdentifier;


-(NSString*)cellIdentifier:(NSIndexPath*)indexPath;


/**
 @brief 1行あたりのセル表示数を指定した場合のセルの大きさを計算する
 @param [fixedCounts] 1行あたりのセル表示数
 @return セルのサイズ
 */
-(CGSize)itemSizeForFixedCellsPerRow:(NSInteger)fixedCounts;

@end

/*
 -(void)viewDidLayoutSubviews
 {
 LOG();
 
 if (collectionView_) {
 
 CGRect rect = collectionView_.frame;
 CGFloat bottom = 10; // 0;
 
 CGFloat top = 5;
 CGFloat side = 7;
 
 UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)(collectionView_.collectionViewLayout);
 layout.minimumInteritemSpacing = 5;
 layout.minimumLineSpacing = 5; //5;
 layout.sectionInset = UIEdgeInsetsMake(top, side, bottom, side);
 
 CGFloat width = rect.size.width/2 - layout.minimumLineSpacing*2;
 if (self.apiHelper.apiPath == ApiPathEvent) {
 CGFloat scale = 1.8;
 layout.itemSize = CGSizeMake(floorf(width), floorf(width*scale));
 }else{
 layout.itemSize = CGSizeMake(floorf(width), floorf(width)+45.0);
 }
 
 [collectionView_ setCollectionViewLayout:layout];
 }
 }
 
 */
