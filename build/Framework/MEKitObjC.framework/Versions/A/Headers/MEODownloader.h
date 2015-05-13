//
//  MEODownloader.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/01/11.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEOCachedData.h"

@class MEODownloader;

typedef void (^MEODownloaderCompletion)(MEODownloader *downloader);


@protocol MEODownloaderDelegate <NSObject>
-(void)doMEODownloaderFinished:(MEODownloader*)downloader data:(NSMutableData*)data;
-(void)doMEODownloaderFailed:(MEODownloader*)downloader;
@end

@interface MEODownloader : NSObject < NSURLConnectionDelegate  >

@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSError *error;
@property (copy) MEODownloaderCompletion completion;
@property id userInfo;
@property id<MEODownloaderDelegate> delegate;
@property BOOL finished;

-(void)start;
-(void)start:(NSString*)urlString;
-(void)cancel;
-(UIImage*)imageFromResponseData;

@end
