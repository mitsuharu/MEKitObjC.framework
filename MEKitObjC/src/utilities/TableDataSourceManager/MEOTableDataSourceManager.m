//
//  TableDataSource.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/04/19.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOTableDataSourceManager.h"
#import "MEOUtilities.h"


#pragma mark - TableDataSourceManager -

@interface MEOTableDataSourceManager () <NSFetchedResultsControllerDelegate>
{
    NSMutableArray *dataSources_;
    NSString *cellIdentifier_;
    __weak id<MEOTableDataSourceManagerDelegate> delegate_;

    NSString *strNowLoading_;
    NSString *strLastUpdate_;
    
    UITableView *tableView_;
    UIRefreshControl *refreshControl_;
    NSString *refreshControlTitle_;
    NSDate *refreshControlDate_;
    UIFont *refreshControlTitleFont_;
    UIColor *refreshControlTitleColor_;
    
    NSFetchedResultsController *fetchedResultsController_;
    
    BOOL showNowLoadingCell_;
    MEOTableDataSource *nowLoadingTableDataSource_;
    
    BOOL showNotFoundCell_;
    MEOTableDataSource *notFoundTableDataSoruce_;
    
    BOOL dynamicCellHeight_;
}

-(void)initilize;

-(MEOTableDataSource*)nowLoadingTableDataSource;
-(MEOTableDataSource*)notFoundTableDataSoruce;

@end

@implementation MEOTableDataSourceManager : NSObject

@synthesize dataSources = dataSources_;
@synthesize cellIdentifier = cellIdentifier_;
@synthesize delegate = delegate_;
@synthesize fetchedResultsController = fetchedResultsController_;
@synthesize showNotFoundCell = showNotFoundCell_;
@synthesize showNowLoadingCell = showNowLoadingCell_;
@synthesize dynamicCellHeight = dynamicCellHeight_;

-(id)init
{
    if (self = [super init]) {
        [self initilize];
    }
    return self;
}

-(id)initWithDelegate:(id<MEOTableDataSourceManagerDelegate>)delegate
            tableView:(UITableView*)tableView
       cellIdentifier:(NSString*)cellIdentifier
{
    if (self = [super init]) {
        [self initilize];
        delegate_ = delegate;
        tableView_ = tableView;
        tableView_.delegate = self;
        tableView_.dataSource = self;
        cellIdentifier_ = cellIdentifier;
        
        if (tableView_ && tableView_.estimatedRowHeight > 0) {
            tableView_.rowHeight = UITableViewAutomaticDimension;
        }
    }
    return self;
}

-(void)dealloc{
    [self initilize];    
}

-(void)initilize{
    dynamicCellHeight_ = NO;
    dataSources_ = nil;
    cellIdentifier_ = @"cell";
    
    strNowLoading_ = [MEOUtilities localizedString:@"NowLoading"];
    strLastUpdate_ = [MEOUtilities localizedString:@"LastUpdate"];
    refreshControl_ = nil;
    refreshControlDate_ = nil;
    refreshControlTitle_ = nil;
    tableView_ = nil;
    fetchedResultsController_ = nil;
    
    showNotFoundCell_ = NO;
    showNowLoadingCell_ = NO;
    nowLoadingTableDataSource_ = nil;
    notFoundTableDataSoruce_ = nil;
    
    refreshControlTitleFont_ = nil;
    refreshControlTitleColor_ = nil;
}


#pragma mark - IO

-(id)dataSource:(NSIndexPath*)indexPath
{
    MEOTableDataSource *tds = nil;
    if (indexPath.section < dataSources_.count) {
        tds = [dataSources_ objectAtIndex:indexPath.section];
    }
    if (tds && tds.dataSource && indexPath.row < tds.dataSource.count) {
        return [tds.dataSource objectAtIndex:indexPath.row];
    }else{
        return nil;
    }
}

-(id)detailSource:(NSIndexPath*)indexPath
{
    MEOTableDataSource *tds = nil;
    if (indexPath.section < dataSources_.count) {
        tds = [dataSources_ objectAtIndex:indexPath.section];
    }
    if (tds && tds.detailSource && indexPath.row < tds.detailSource.count) {
        return [tds.detailSource objectAtIndex:indexPath.row];
    }else{
        return nil;
    }
}

-(NSString*)cellIdentifier:(NSIndexPath*)indexPath
{
    MEOTableDataSource *tds = nil;
    if (indexPath.section < dataSources_.count) {
        tds = [dataSources_ objectAtIndex:indexPath.section];
    }
    if (tds && tds.cellIdentifiers && indexPath.row < tds.cellIdentifiers.count) {
        return [tds.cellIdentifiers objectAtIndex:indexPath.row];
    }else{
        return cellIdentifier_;
    }
}

-(NSString*)text:(NSIndexPath*)indexPath
{
    id obj = [self dataSource:indexPath];
    NSString *str = nil;
    if (obj && [obj isKindOfClass:[NSString class]]) {
        str = (NSString*)obj;
    }
    return str;
}

-(NSString*)detailText:(NSIndexPath*)indexPath
{
    id obj = [self detailSource:indexPath];
    NSString *str = nil;
    if (obj && [obj isKindOfClass:[NSString class]]) {
        str = (NSString*)obj;
    }
    return str;
}

-(CGFloat)cellHeight:(NSIndexPath*)indexPath
{
    CGFloat height = tableView_.rowHeight;

    MEOTableDataSource *tds = nil;
    if (indexPath.section < dataSources_.count) {
        tds = [dataSources_ objectAtIndex:indexPath.section];
    }
    if (tds && tds.cellHeights && indexPath.row < tds.cellHeights.count) {
        NSNumber *num = [tds.cellHeights objectAtIndex:indexPath.row];
        if (num && [num isKindOfClass:[NSNumber class]]) {
            height = [num floatValue];
        }
    }else{
    }
    return height;
}

-(void)setDynamicCellHeight:(BOOL)dynamicCellHeight
{
    dynamicCellHeight_ = dynamicCellHeight;
}

#pragma mark - NowLoadingCell

-(MEOTableDataSource*)nowLoadingTableDataSource
{
    if (nowLoadingTableDataSource_) {
        [self setNowLoadingCell:nil cellIdentifier:nil];
    }
    return nowLoadingTableDataSource_;
}

-(void)reloadNowLoadingCell:(BOOL)nowLoadingCell
{
    showNowLoadingCell_ = nowLoadingCell;
    [tableView_ reloadData];
    [self setRefreshControlDate:[NSDate date]];
}

-(void)setNowLoadingCell:(NSString*)title cellIdentifier:(NSString*)cellIdentifier
{
    nowLoadingTableDataSource_ = [[MEOTableDataSource alloc] init];
    nowLoadingTableDataSource_.dataSource = [[NSMutableArray alloc] initWithCapacity:1];
    if (title && title.length > 0) {
        [nowLoadingTableDataSource_.dataSource addObject:title];
    }else{
        [nowLoadingTableDataSource_.dataSource addObject:[MEOUtilities localizedString:@"NowLoading"]];
    }
    
    nowLoadingTableDataSource_.cellIdentifiers = [[NSMutableArray alloc] initWithCapacity:1];
    if (cellIdentifier && cellIdentifier.length > 0) {
        [nowLoadingTableDataSource_.cellIdentifiers addObject:cellIdentifier];
    }else if (self.cellIdentifier && self.cellIdentifier.length > 0) {
        [nowLoadingTableDataSource_.cellIdentifiers addObject:self.cellIdentifier];
    }
}

#pragma mark - NotFoundCell

-(MEOTableDataSource*)notFoundTableDataSoruce
{
    if (notFoundTableDataSoruce_ == nil) {
        [self setNotFoundCell:nil cellIdentifier:nil];
    }
    return notFoundTableDataSoruce_;
}

-(void)reloadNotFoundCell:(BOOL)showNotFoundCell
{
    showNotFoundCell_ = showNotFoundCell;
    [tableView_ reloadData];
    [self setRefreshControlDate:[NSDate date]];
}

-(void)setNotFoundCell:(NSString*)title cellIdentifier:(NSString*)cellIdentifier
{
    notFoundTableDataSoruce_ = [[MEOTableDataSource alloc] init];
    notFoundTableDataSoruce_.dataSource = [[NSMutableArray alloc] initWithCapacity:1];
    if (title && title.length > 0) {
        [notFoundTableDataSoruce_.dataSource addObject:title];
    }else{
        [notFoundTableDataSoruce_.dataSource addObject:[MEOUtilities localizedString:@"NotFound"]];
    }
    
    notFoundTableDataSoruce_.cellIdentifiers = [[NSMutableArray alloc] initWithCapacity:1];
    if (cellIdentifier && cellIdentifier.length > 0) {
        [notFoundTableDataSoruce_.cellIdentifiers addObject:cellIdentifier];
    }else if (self.cellIdentifier && self.cellIdentifier.length > 0) {
        [notFoundTableDataSoruce_.cellIdentifiers addObject:self.cellIdentifier];
    }
}

#pragma mark - NSFetchedResultsController

-(void)setFetchedResultsController:(NSFetchedResultsController*)fetchedResultsController
{
    fetchedResultsController_ = fetchedResultsController;
    if (fetchedResultsController_) {
        fetchedResultsController_.delegate = self;
        NSError *error = nil;
        if ([fetchedResultsController_ performFetch:&error] == NO) {
            NSLog(@"error %@", error.localizedDescription);
        }
    }
}


#pragma mark - RefreshControl

-(void)addRefreshControlWithFont:(UIFont*)font color:(UIColor*)color
{
    refreshControlTitleFont_ = font;
    refreshControlTitleColor_ = color;
    if (tableView_ && refreshControl_ == nil) {
        refreshControl_ = [[UIRefreshControl alloc] init];
        [self setRefreshControlTitle:refreshControlTitle_
                                date:refreshControlDate_];
        [refreshControl_ addTarget:self
                            action:@selector(doRefreshControl:)
                  forControlEvents:(UIControlEventValueChanged)];
        [tableView_ setAlwaysBounceVertical:YES];
        [tableView_ addSubview:refreshControl_];
        
        NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
        [refreshControl_ addObserver:self
                          forKeyPath:@"refreshing"
                             options:options
                             context:nil];
    }
}

-(void)addRefreshControl
{
    [self addRefreshControlWithFont:nil color:nil];
}

-(void)removeRefreshControl
{
    if (refreshControl_) {
        [refreshControl_ removeFromSuperview];
    }
    refreshControl_ = nil;
}


-(void)stopRefreshControl
{
    if (refreshControl_) {
        if (refreshControl_.refreshing) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [refreshControl_ endRefreshing];
            });
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self setRefreshControlDate:[NSDate date]];
            });
        }else if (refreshControlDate_ == nil){
            [self setRefreshControlDate:[NSDate date]];
        }
    }
}

-(void)setRefreshControlDate:(NSDate*)date
{
    refreshControlDate_ = date;
    if (refreshControl_) {
        [self setRefreshControlTitle:refreshControlTitle_
                                date:refreshControlDate_];
    }
}

-(BOOL)passedMoreThanOneDay
{
    BOOL result = false;
    if (refreshControlDate_) {
        NSDate *nowDate = [NSDate date];
        NSTimeInterval interval = [nowDate timeIntervalSinceDate:refreshControlDate_];
        float absInterval = fabs(interval);
        float days = absInterval/(60*60*24);
        if (days > 1.0) {
            result = true;
        }
    }
    return result;
}

-(void)setRefreshControlTitle:(NSString*)title date:(NSDate*)date
{
    refreshControlDate_ = date;
    NSString *dateStr = nil;
    if (date) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.timeZone = [NSTimeZone systemTimeZone];
        formatter.locale = [NSLocale systemLocale];
        
        formatter.dateFormat = @"yyyy/MM/dd HH:mm:ss";
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 ){
            // iOS8以上
            if ([formatter.calendar.calendarIdentifier isEqualToString:NSCalendarIdentifierJapanese]) {                formatter.dateFormat = @"GGyy年MM月dd日 HH時mm分ss秒";
            }
        }else{
            if ([formatter.calendar.calendarIdentifier isEqualToString:NSJapaneseCalendar]) {
                formatter.dateFormat = @"GGyy年MM月dd日 HH時mm分ss秒";
            }
        }

        
        dateStr = [formatter stringFromDate:date];
    }
    
    refreshControlTitle_ = title;
    NSMutableString *titleStr = [[NSMutableString alloc] initWithCapacity:1];
    if (title && title.length > 0) {
        [titleStr appendString:title];
    }else{
        [titleStr appendString:strLastUpdate_];
    }
    if (dateStr && dateStr.length > 0) {
        [titleStr appendFormat:@" %@", dateStr];
    }else{
        [titleStr appendFormat:@" -"];
    }
    
    
    UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    if (refreshControlTitleFont_) {
        font = refreshControlTitleFont_;
    }
    
    UIColor *color = [UIColor grayColor];
    if (refreshControlTitleColor_) {
        color = refreshControlTitleColor_;
    }
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                color, NSForegroundColorAttributeName,
                                font, NSFontAttributeName, nil];

    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:titleStr
                                                                               attributes:attributes];
    if (refreshControl_) {
        refreshControl_.tintColor = refreshControlTitleColor_;
        refreshControl_.attributedTitle = attStr;
    }
}

-(void)doRefreshControl:(UIRefreshControl*)sender
{
    if (refreshControl_) {
        if (refreshControl_.refreshing) {
            if (delegate_ && [delegate_ respondsToSelector:@selector(tableDataSourceManager:didRefreshControl:)]) {
                [delegate_ tableDataSourceManager:self
                                didRefreshControl:refreshControl_];
            }
        }
    }
}




#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = 0;
    if (showNotFoundCell_) {
        sections = 1;
    }else if (fetchedResultsController_ && fetchedResultsController_.sections) {
        sections = [fetchedResultsController_.sections count];
    }else if (dataSources_) {
        sections = dataSources_.count;
    }
    return sections;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row = 0;
    @try {
        if (showNotFoundCell_) {
            row = 1;
        }else if (fetchedResultsController_ && fetchedResultsController_.sections) {
            id<NSFetchedResultsSectionInfo> info = [fetchedResultsController_.sections objectAtIndex:section];
            row = [info numberOfObjects];
        }else if (dataSources_) {
            MEOTableDataSource *tds = [dataSources_ objectAtIndex:section];
            row = tds.dataSource.count;
        }
        
        if (showNowLoadingCell_) {
            if (showNotFoundCell_ || row == 0) {
            }else{
                row += 1;
            }
        }

    }
    @catch (NSException *exception) {
        NSLog(@"exception:%@", exception.reason);
    }
    @finally {
    }
    return row;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view = Nil;
//    if (delegate_ && [delegate_ respondsToSelector:@selector(tableDataSourceManager:tableView:viewForHeaderInSection:)]) {
//        view = [delegate_ tableDataSourceManager:self
//                                       tableView:tableView
//                          viewForHeaderInSection:section];
//    }
//    return view;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//
//    return 0.1f;
//}


-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;    
    @try {
        if (showNotFoundCell_) {
            
        }
        if (fetchedResultsController_ && fetchedResultsController_.sections) {
            id<NSFetchedResultsSectionInfo> info = [fetchedResultsController_.sections objectAtIndex:section];
            title = [info name];
        }else if (dataSources_) {
            MEOTableDataSource *tds = [dataSources_ objectAtIndex:section];
            title = tds.headerString;
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    return title;
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *title = nil;
    @try {
        if (showNotFoundCell_) {
            
        }
        if (fetchedResultsController_ && fetchedResultsController_.sections) {
        }else if (dataSources_) {
            MEOTableDataSource *tds = [dataSources_ objectAtIndex:section];
            title = tds.footerString;
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
    }    
    return title;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [self cellHeight:indexPath];
    
    if (dynamicCellHeight_) {
        MEOTableDataSource *tds = [dataSources_ objectAtIndex:indexPath.section];
        
        CGFloat offset = 0;
        NSString *str = nil;
        if (tds.dataSource && indexPath.row < tds.dataSource.count) {
            id obj = [tds.dataSource objectAtIndex:indexPath.row];
            if ([obj isKindOfClass:[NSString class]]) {
                str = (NSString*)obj;
            }
        }
        if (tds.detailSource && indexPath.row < tds.detailSource.count) {
            id obj = [tds.detailSource objectAtIndex:indexPath.row];
            if ([obj isKindOfClass:[NSString class]]) {
                NSString *temp = (NSString*)obj;
                if (str && str.length < temp.length) {
                    str = temp;
                    offset = 30;
                }
            }
        }
        
        if (str && str.length > 0) {
            CGFloat margin = 10.0f;
            CGSize maxSize = CGSizeMake(tableView.frame.size.width - (margin * 2) - offset,
                                           CGFLOAT_MAX);
            UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
            CGRect rect = [str boundingRectWithSize:maxSize
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:font}
                                            context:nil];
            CGFloat tempHeight = ceilf(rect.size.height + 2*margin);
            if (tempHeight > height) {
                height = tempHeight;
            }
       }
    }
    
    if (delegate_
        && [delegate_ respondsToSelector:@selector(tableDataSourceManager:tableView:heightForRowAtIndexPath:)]) {
        
        CGFloat tempHeight = [delegate_ tableDataSourceManager:self
                                                     tableView:tableView
                                       heightForRowAtIndexPath:indexPath];
        if (tempHeight > 0) {
            height = tempHeight;
        }
    }
    
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = nil;
    
    if (delegate_
        && [delegate_ respondsToSelector:@selector(tableDataSourceManager:tableView:viewForHeaderInSection:)]) {
        view = [delegate_ tableDataSourceManager:self
                                       tableView:tableView
                          viewForHeaderInSection:section];
    }
    
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = UITableViewAutomaticDimension;

    UIView *view = [self tableView:tableView viewForHeaderInSection:section];
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
    if (view) {
        height = view.frame.size.height;
    }else if (title && title.length > 0){
        height = UITableViewAutomaticDimension;
    }else{
        height = 0.0;
    }
    
    return height;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = nil;
    
    if (delegate_
        && [delegate_ respondsToSelector:@selector(tableDataSourceManager:tableView:viewForFooterInSection:)]) {
        view = [delegate_ tableDataSourceManager:self
                                       tableView:tableView
                          viewForFooterInSection:section];
    }
    
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = UITableViewAutomaticDimension;
    
    UIView *view = [self tableView:tableView viewForFooterInSection:section];
    NSString *title = [self tableView:tableView titleForFooterInSection:section];
    if (view) {
        height = view.frame.size.height;
    }else if (title && title.length > 0)
        height = UITableViewAutomaticDimension;
    else{
        height = 0.0;
    }
    
    return height;
}


- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if (delegate_ && [delegate_ respondsToSelector:@selector(tableDataSourceManager:tableView:willDisplayHeaderView:forSection:)]) {
        [delegate_ tableDataSourceManager:self
                                tableView:tableView
                    willDisplayHeaderView:view
                               forSection:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //DLog(@"");
    
    UITableViewCell *cell = nil;
    
    MEOTableDataSource *tds0 = [dataSources_ objectAtIndex:indexPath.section];
    NSInteger sourceConut = tds0.dataSource.count;
    
    SEL selector = @selector(tableDataSourceManager:tableView:cellForRowAtIndexPath:);
    
    if (showNowLoadingCell_ && indexPath.row == sourceConut) {
        
        MEOTableDataSource *tds = [self nowLoadingTableDataSource];
        cell = [tableView dequeueReusableCellWithIdentifier:tds.cellIdentifiers.firstObject];
        cell.textLabel.text = tds.dataSource.firstObject;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
        tds.tag = 0;
        
        SEL selector2 = @selector(tableDataSourceManager:didShowNowLoadingCell:);
        if (delegate_ && [delegate_ respondsToSelector:selector2]) {
            [delegate_ tableDataSourceManager:self
                        didShowNowLoadingCell:[tableView_ cellForRowAtIndexPath:indexPath]];
        }
        
    }else if (showNotFoundCell_) {
        
        MEOTableDataSource *tds = [self notFoundTableDataSoruce];
        cell = [tableView dequeueReusableCellWithIdentifier:tds.cellIdentifiers.firstObject];
        cell.textLabel.text = tds.dataSource.firstObject;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
        
    }else if (delegate_ &&[delegate_ respondsToSelector:selector]) {
 
        cell = [delegate_ tableDataSourceManager:self
                                       tableView:tableView
                           cellForRowAtIndexPath:indexPath];
    }
    
    if (cell == nil) {
        cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifier:indexPath]];
        @try {
            
            if (fetchedResultsController_ && fetchedResultsController_.sections) {
            }else if (dataSources_) {
                MEOTableDataSource *tds = [dataSources_ objectAtIndex:indexPath.section];
                
                if (tds.dataSource && indexPath.row < tds.dataSource.count) {
                    cell.accessoryView = nil;
                    NSString *str = [tds.dataSource objectAtIndex:indexPath.row];
                    if (str && [str isKindOfClass:[NSString class]]) {
                        cell.textLabel.text = str;
                        [cell.textLabel setNumberOfLines:1];
                        if (dynamicCellHeight_) {
                            [cell.textLabel setNumberOfLines:0];
                            [cell.textLabel sizeToFit];
                        }
                    }
                }
                
                if (tds.detailSource && indexPath.row < tds.detailSource.count) {
                    NSString *detail = [tds.detailSource objectAtIndex:indexPath.row];
                    if (detail && [detail isKindOfClass:[NSString class]]) {
                        cell.detailTextLabel.text = detail;
                        [cell.detailTextLabel setNumberOfLines:1];
                        if (dynamicCellHeight_) {
                            [cell.detailTextLabel setNumberOfLines:0];
                            [cell.detailTextLabel sizeToFit];
                        }
                    }
                }
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
    }
    
    return cell;
}

#pragma mark - edit action

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

// http://dev.classmethod.jp/references/ios-8-uitableviewrowaction/
- (NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = nil;
    
    MEOTableDataSource *tds = [dataSources_ objectAtIndex:indexPath.section];
    if (tds.editActions && tds.editActions.count > indexPath.row) {
        arr = (NSArray *)[tds.editActions objectAtIndex:indexPath.row];
    }
    
    return arr;
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
        SEL selector = @selector(tableDataSourceManager:tableView:didScrollStopped:);
        if (delegate_ && [delegate_ respondsToSelector:selector]) {
            [delegate_ tableDataSourceManager:self
                                    tableView:tableView_
                             didScrollStopped:[tableView_ indexPathsForVisibleRows]];
        }
    }
}

// 画面が静止したときに呼ばれる
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    SEL selector = @selector(tableDataSourceManager:tableView:didScrollStopped:);
    if (delegate_ && [delegate_ respondsToSelector:selector]) {
        [delegate_ tableDataSourceManager:self
                                tableView:tableView_
                         didScrollStopped:[tableView_ indexPathsForVisibleRows]];
    }
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SEL selector = @selector(tableDataSourceManager:tableView:didSelectRowAtIndexPath:);
    SEL selector2 = @selector(tableDataSourceManager:didSelectNowLoadingCell:);
    MEOTableDataSource *tds0 = [dataSources_ objectAtIndex:indexPath.section];    
    if (showNowLoadingCell_ && indexPath.row == tds0.dataSource.count) {
        if (delegate_ && [delegate_ respondsToSelector:selector2]) {
            [delegate_ tableDataSourceManager:self
                      didSelectNowLoadingCell:[tableView_ cellForRowAtIndexPath:indexPath]];
        }
    }else if (delegate_ &&[delegate_ respondsToSelector:selector]) {
        [delegate_ tableDataSourceManager:self
                                tableView:tableView
                  didSelectRowAtIndexPath:indexPath];
    }
}


@end
