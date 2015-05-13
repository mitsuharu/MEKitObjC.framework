//
//  TableDataSource.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/04/19.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MEOTableDataSource.h"

@class MEOTableDataSourceManager;

@protocol MEOTableDataSourceManagerDelegate <NSObject>

@optional

-(UITableViewCell *)tableDataSourceManager:(MEOTableDataSourceManager*)manager
                                 tableView:(UITableView *)tableView
                     cellForRowAtIndexPath:(NSIndexPath *)indexPath;

-(void)tableDataSourceManager:(MEOTableDataSourceManager*)manager
                    tableView:(UITableView *)tableView
      didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

-(CGFloat)tableDataSourceManager:(MEOTableDataSourceManager*)manager
                       tableView:(UITableView *)tableView
         heightForRowAtIndexPath:(NSIndexPath *)indexPath;

-(UIView*)tableDataSourceManager:(MEOTableDataSourceManager*)manager
                       tableView:(UITableView *)tableView
          viewForFooterInSection:(NSInteger)section;

-(UIView *)tableDataSourceManager:(MEOTableDataSourceManager*)manager
                        tableView:(UITableView *)tableView
        viewForHeaderInSection:(NSInteger)section;

-(void)tableDataSourceManager:(MEOTableDataSourceManager*)manager
                    tableView:(UITableView *)tableView
        willDisplayHeaderView:(UIView *)view
                   forSection:(NSInteger)section;

-(void)tableDataSourceManager:(MEOTableDataSourceManager*)manager
            didRefreshControl:(UIRefreshControl *)refreshControl;

-(void)tableDataSourceManager:(MEOTableDataSourceManager*)manager
         didShowNowLoadingCell:(UITableViewCell *)nowLoadingCell;

-(void)tableDataSourceManager:(MEOTableDataSourceManager*)manager
       didSelectNowLoadingCell:(UITableViewCell *)nowLoadingCell;


/**
 @breif スクロールが止まったときに呼ばれる．主に非同期ダウンロードの表示更新などに用いる
 */
-(void)tableDataSourceManager:(MEOTableDataSourceManager*)manager
                    tableView:(UITableView *)tableView
             didScrollStopped:(NSArray*)visibleIndexPaths;


@end


@interface MEOTableDataSourceManager : NSObject
<
    UITableViewDelegate, UITableViewDataSource
>

@property (nonatomic, retain) NSMutableArray *dataSources;
@property (nonatomic, retain) NSString *cellIdentifier;
@property (nonatomic, retain) id<MEOTableDataSourceManagerDelegate> delegate;

@property (nonatomic) BOOL showNotFoundCell;
@property (nonatomic) BOOL showNowLoadingCell;
@property (nonatomic) BOOL dynamicCellHeight;

@property (nonatomic, retain, setter=setFetchedResultsController:) NSFetchedResultsController *fetchedResultsController;

-(id)initWithDelegate:(id<MEOTableDataSourceManagerDelegate>)delegate
            tableView:(UITableView*)tableView
       cellIdentifier:(NSString*)cellIdentifier;


-(void)setDynamicCellHeight:(BOOL)dynamicCellHeight;

-(id)dataSource:(NSIndexPath*)indexPath;
-(id)detailSource:(NSIndexPath*)indexPath;
-(NSString*)cellIdentifier:(NSIndexPath*)indexPath;
-(NSString*)text:(NSIndexPath*)indexPath;
-(NSString*)detailText:(NSIndexPath*)indexPath;
-(CGFloat)cellHeight:(NSIndexPath*)indexPath;

-(void)reloadNowLoadingCell:(BOOL)nowLoadingCell;
-(void)setNowLoadingCell:(NSString*)title cellIdentifier:(NSString*)cellIdentifier;

-(void)reloadNotFoundCell:(BOOL)showNotFoundCell;
-(void)setNotFoundCell:(NSString*)title cellIdentifier:(NSString*)cellIdentifier;

-(void)addRefreshControl;
-(void)addRefreshControlWithFont:(UIFont*)font color:(UIColor*)color;
-(void)removeRefreshControl;
-(void)stopRefreshControl;
-(void)setRefreshControlDate:(NSDate*)date;
-(void)setRefreshControlTitle:(NSString*)title date:(NSDate*)date;

-(void)setFetchedResultsController:(NSFetchedResultsController*)fetchedResultsController;


@end
