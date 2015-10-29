//
//  MEOCollectionDataSourceManager.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/04/01.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOCollectionDataSourceManager.h"
#import "MEOCollectionDataSource.h"


@interface MEOCollectionDataSourceManager ()
{
}

/**
 @brief 初期化
 */
-(void)initialize;

@end


@implementation MEOCollectionDataSourceManager

#pragma mark - Lifecycle

-(id)initWithDelegate:(id<MEOCollectionDataSourceManagerDelegate>)delegate
       collectionView:(UICollectionView*)collectionView
       cellIdentifier:(NSString*)cellIdentifier
{
    if (self = [super init]) {
        self.cellIdentifier = cellIdentifier;
        self.collectionView = collectionView;
        if (self.collectionView) {
            self.collectionView.dataSource = self;
            self.collectionView.delegate = self;
        }
        self.delegate = delegate;
    }
    return self;
}


- (void)dealloc
{
    [self initialize];
}

-(void)initialize
{
    self.delegate = nil;
    self.collectionView.delegate = nil;
    self.collectionView = nil;
}

#pragma mark - Parameter io

-(NSString*)cellIdentifier:(NSIndexPath*)indexPath
{
    NSString *cIdentifier = self.cellIdentifier;
    MEOCollectionDataSource *ds = nil;
    if (indexPath.section < self.dataSources.count) {
        ds = self.dataSources[indexPath.section];
    }
    if (ds && ds.cellIdentifiers && indexPath.row < ds.cellIdentifiers.count) {
        cIdentifier = ds.cellIdentifiers[indexPath.row];
    }
    return cIdentifier;
}

#pragma mark - UIScrollViewDelegate

// スクロール中に呼ばれる
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}

// ドラッグが終了した時に呼ばれる
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        SEL selector = @selector(collectionDataSourceManager:collectionView:didScrollStopped:);
        if (self.delegate
            && [self.delegate respondsToSelector:selector]) {
            [self.delegate collectionDataSourceManager:self
                                        collectionView:self.collectionView
                                      didScrollStopped:[self.collectionView indexPathsForVisibleItems]];
        }
    }
}

// 画面が静止したときに呼ばれる
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    SEL selector = @selector(collectionDataSourceManager:collectionView:didScrollStopped:);
    if (self.delegate
        && [self.delegate respondsToSelector:selector]) {
        [self.delegate collectionDataSourceManager:self
                                    collectionView:self.collectionView
                                  didScrollStopped:[self.collectionView indexPathsForVisibleItems]];
    }
}

#pragma mark - help UICollectionViewDelegateFlowLayout

-(CGSize)itemSizeForFixedCellsPerRow:(NSInteger)fixedCounts
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)(self.collectionView.collectionViewLayout);
    CGSize itemSize = layout.itemSize;
    
    if (fixedCounts > 0) {
        CGRect rect = self.collectionView.frame;
        if (rect.size.width == 0) {
            rect = self.collectionView.superview.frame;
        }
        UIEdgeInsets inset = layout.sectionInset;
        
        CGFloat width = (rect.size.width - inset.left - inset.right - layout.minimumInteritemSpacing*(fixedCounts-1))/fixedCounts;
        //        CGFloat width = (rect.size.width- inset.left - inset.bottom)/fixedCounts - layout.minimumLineSpacing*2;
        CGFloat height = floorf((itemSize.height/itemSize.width)*width);
        itemSize = CGSizeMake(width, height);
    }
    
    return itemSize;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)(collectionViewLayout);
    CGSize itemSize = layout.itemSize;
    
    SEL selector = @selector(collectionDataSourceManager:collectionView:layout:sizeForItemAtIndexPath:);
    if (self.delegate
        && [self.delegate respondsToSelector:selector]) {
        CGSize tempSize = [self.delegate collectionDataSourceManager:self
                                                      collectionView:collectionView
                                                              layout:collectionViewLayout
                                              sizeForItemAtIndexPath:indexPath];
        
        if (tempSize.width > 0 && tempSize.height > 0) {
            itemSize = tempSize;
        }
    }
    
    return itemSize;
}

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)(collectionViewLayout);
    CGSize itemSize = layout.headerReferenceSize;
    
    SEL selector = @selector(collectionDataSourceManager:collectionView:layout:referenceSizeForHeaderInSection:);
    if (self.delegate
        && [self.delegate respondsToSelector:selector]) {
        CGSize tempSize = [self.delegate collectionDataSourceManager:self
                                                      collectionView:collectionView
                                                              layout:collectionViewLayout
                                              referenceSizeForHeaderInSection:section];
        
        if (tempSize.width > 0 && tempSize.height > 0) {
            itemSize = tempSize;
        }
    }
    
    return itemSize;
}

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)(collectionViewLayout);
    CGSize itemSize = layout.footerReferenceSize;
    
    SEL selector = @selector(collectionDataSourceManager:collectionView:layout:referenceSizeForFooterInSection:);
    if (self.delegate
        && [self.delegate respondsToSelector:selector]) {
        CGSize tempSize = [self.delegate collectionDataSourceManager:self
                                                      collectionView:collectionView
                                                              layout:collectionViewLayout
                                     referenceSizeForFooterInSection:section];
        
        if (tempSize.width > 0 && tempSize.height > 0) {
            itemSize = tempSize;
        }
    }
    
    return itemSize;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger sections = 0;
    if (self.dataSources.count > 0) {
        sections = self.dataSources.count;
    }
    return sections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    NSInteger row = 0;
    
    @try {
        if (self.dataSources.count > 0) {
            if (section < self.dataSources.count) {
                MEOCollectionDataSource *ds = self.dataSources[section];
                row = ds.dataSource.count;
            }
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"%s, exception %@", __func__, exception);
    }
    @finally {
    }
    
    return row;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    
    MEOCollectionDataSource *ds = nil;
    if (indexPath.section < self.dataSources.count) {
        ds = self.dataSources[indexPath.section];
    }
    
    SEL selector = @selector(collectionDataSourceManager:collectionView:cellForItemAtIndexPath:);
    if (self.delegate && [self.delegate respondsToSelector:selector]) {
        cell = [self.delegate collectionDataSourceManager:self
                                           collectionView:collectionView
                                   cellForItemAtIndexPath:indexPath];
    }
    
    if (cell == nil) {
       cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self cellIdentifier:indexPath]
                                                        forIndexPath:indexPath];
    }
    
    return cell;
}


-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView
         viewForSupplementaryElementOfKind:(NSString *)kind
                               atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = [UICollectionReusableView new];
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        SEL selector = @selector(collectionDataSourceManager:collectionView:headerViewAtIndexPath:);
        if (self.delegate
            && [self.delegate respondsToSelector:selector]) {
            reusableview = [self.delegate collectionDataSourceManager:self
                                                       collectionView:collectionView
                                                headerViewAtIndexPath:indexPath];
        }else if (self.headerReuseIdentifier.length > 0){
            reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                              withReuseIdentifier:self.headerReuseIdentifier
                                                                     forIndexPath:indexPath];
        }
    }else if ([kind isEqualToString:UICollectionElementKindSectionFooter]){
        
        SEL selector = @selector(collectionDataSourceManager:collectionView:footerViewAtIndexPath:);
        if (self.delegate
            && [self.delegate respondsToSelector:selector]) {
            reusableview = [self.delegate collectionDataSourceManager:self
                                                       collectionView:collectionView
                                                footerViewAtIndexPath:indexPath];
        }else if (self.footerReuseIdentifier.length > 0){
            reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                              withReuseIdentifier:self.footerReuseIdentifier
                                                                     forIndexPath:indexPath];
        }
    }
    
    return reusableview;
}


#pragma mark - UICollectionViewDelegate


- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
    
    SEL selector = @selector(collectionDataSourceManager:collectionView:didSelectItemAtIndexPath:);
    if (self.delegate
        && [self.delegate respondsToSelector:selector]) {
        [self.delegate collectionDataSourceManager:self
                                    collectionView:collectionView
                          didSelectItemAtIndexPath:indexPath];
    }
    
}



@end
