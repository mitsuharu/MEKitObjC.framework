//
//  MEOImageDownloader.h
//  DMVideo
//
//  Created by Mitsuharu Emoto on 2016/07/14.
//  Copyright © 2016年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const MEOApiOptionKey;
extern NSString *const MEOCacheManagerOptionKey;

@class MEOApiOption;
@class MEOCacheManagerOption;
typedef void (^MEOImageDownloaderCompletion)(UIImage *image);

/**
 *  MEOApiManagerとMEOCacheManagerで連携して画像をダウンロードする
 */
@interface MEOImageDownloader : NSObject

+ (void)setSimultaneousDownloadCount:(NSInteger)count;

+ (void)imageUrl:(NSString*)imageUrl
           cache:(MEOImageDownloaderCompletion)cache
        download:(MEOImageDownloaderCompletion)download;

/**
 * MEOApiManagerとMEOCacheManagerで連携して画像をダウンロードする
 *
 *  @param imageUrl 画像URL
 *  @param option   例：@{MEOCacheManagerOptionKey:cacheManagerOption}
 *  @param cache    キャッシュデータ
 *  @param download ダウンロードデータ
 */
+ (void)imageUrl:(NSString*)imageUrl
          option:(NSDictionary*)option
           cache:(MEOImageDownloaderCompletion)cache
        download:(MEOImageDownloaderCompletion)download;

- (BOOL)cancel;

- (void)imageUrl:(NSString*)imageUrl
           cache:(MEOImageDownloaderCompletion)cache
        download:(MEOImageDownloaderCompletion)download;

- (void)imageUrl:(NSString*)imageUrl
          option:(NSDictionary*)option
           cache:(MEOImageDownloaderCompletion)cache
        download:(MEOImageDownloaderCompletion)download;

@end
