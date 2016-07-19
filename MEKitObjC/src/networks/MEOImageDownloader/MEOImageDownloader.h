//
//  MEOImageDownloader.h
//  DMVideo
//
//  Created by Mitsuharu Emoto on 2016/07/14.
//  Copyright © 2016年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MEOApiOption;
typedef void (^MEOImageDownloaderCompletion)(UIImage *image);

/**
 *  MEOApiManagerとMEOCacheManagerで連携して画像をダウンロードする
 */
@interface MEOImageDownloader : NSObject

+ (void)imageUrl:(NSString*)imageUrl
           cache:(MEOImageDownloaderCompletion)cache
        download:(MEOImageDownloaderCompletion)download;

+ (void)imageUrl:(NSString*)imageUrl
          option:(MEOApiOption*)option
           cache:(MEOImageDownloaderCompletion)cache
        download:(MEOImageDownloaderCompletion)download;


@end
