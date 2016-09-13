//
//  MEOImageDownloader.m
//  DMVideo
//
//  Created by Mitsuharu Emoto on 2016/07/14.
//  Copyright © 2016年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOImageDownloader.h"

#import "MEOApiManager.h"
#import "MEOCacheManager.h"
#import "MEOCache.h"

NSInteger simultaneousDownloadCount = 0;
NSInteger downloadCount = 0;

@implementation MEOImageDownloader

+ (void)setSimultaneousDownloadCount:(NSInteger)count
{
    simultaneousDownloadCount = count;
}

+ (void)imageUrl:(NSString*)imageUrl
           cache:(MEOImageDownloaderCompletion)cache
        download:(MEOImageDownloaderCompletion)download;
{
    MEOApiOption *option = [[MEOApiOption alloc] init];
    option.comparelastModified = true;
    [MEOImageDownloader imageUrl:imageUrl
                          option:option
                           cache:cache
                        download:download];
}


+ (void)imageUrl:(NSString*)imageUrl
          option:(MEOApiOption*)option
           cache:(MEOImageDownloaderCompletion)cache
        download:(MEOImageDownloaderCompletion)download
{
    BOOL comparelastModified = false;
    if (option) {
        comparelastModified = option.comparelastModified;
    }
    
    if (imageUrl && imageUrl.length > 0) {
        MEOCache *meoCache = [MEOCacheManager cacheForKey:imageUrl];
        UIImage *cachedImage = meoCache.image;

        if (cache) {
            cache(cachedImage);
        }
        
        // 画像ダウンロード（共通のためブロック化）
        void (^downloadImage)(void) = ^void (void) {
            
            if (simultaneousDownloadCount > 0
                && downloadCount > simultaneousDownloadCount) {
                // 同時ダウンロード数の上限を超えてるのでダウンロードしない
                if (download) {
                    download(nil);
                }
            }else{
                downloadCount += 1;
                [MEOApiManager download:imageUrl
                                 option:option
                             completion:^(MEOApiManagerResultStatus result,
                                          NSData *data,
                                          NSDictionary *userInfo,
                                          NSInteger httpStatus,
                                          NSError *error)
                 {
                     downloadCount -= 1;
                     UIImage *image = nil;
                     if (error == nil) {
                         image = [[UIImage alloc] initWithData:data];
                         if (image) {
                             [MEOCacheManager setImage:image forKey:imageUrl];
                         }
                     }
                     if (download) {
                         download(image);
                     }
                 }];
            }
        };
        
        if (cachedImage) {
            if (comparelastModified == false) {
            }else{
                [MEOApiManager requestLastModified:imageUrl
                                            option:option
                                        completion:^(MEOApiManagerResultStatus result,
                                                     NSData *data,
                                                     NSDictionary *userInfo,
                                                     NSInteger httpStatus,
                                                     NSError *error)
                 {
                     NSDate *lastModified = [MEOApiManager lastModified:userInfo];
                     if (meoCache.updatedAt
                         && lastModified
                         && [meoCache.updatedAt compare:lastModified] == NSOrderedAscending) {
 
                         // 古いので更新する
                         downloadImage();
//                         [MEOApiManager download:imageUrl
//                                          option:option
//                                      completion:^(MEOApiManagerResultStatus result,
//                                                   NSData *data,
//                                                   NSDictionary *userInfo,
//                                                   NSInteger httpStatus,
//                                                   NSError *error)
//                          {
//                              UIImage *image = nil;
//                              if (error == nil) {
//                                   image = [[UIImage alloc] initWithData:data];
//                                  if (image) {
//                                      [MEOCacheManager setImage:image forKey:imageUrl];
//                                  }
//                              }
//                              if (download) {
//                                  download(image);
//                              }
//                          }];
                     }else{
                     }
                 }];
            }
        }else {
            
            downloadImage();
            
//            [MEOApiManager download:imageUrl
//                             option:option
//                         completion:^(MEOApiManagerResultStatus result,
//                                      NSData *data,
//                                      NSDictionary *userInfo,
//                                      NSInteger httpStatus,
//                                      NSError *error)
//             {
//                 UIImage *image = nil;
//                 if (error == nil) {
//                     image = [[UIImage alloc] initWithData:data];
//                     if (image) {
//                         [MEOCacheManager setImage:image forKey:imageUrl];
//                     }
//                 }
//                 if (download) {
//                     download(image);
//                 }
//             }];
            
        }
    }else{
        if (cache) {
            cache(nil);
        }
        if (download) {
            download(nil);
        }
    }
}

@end
