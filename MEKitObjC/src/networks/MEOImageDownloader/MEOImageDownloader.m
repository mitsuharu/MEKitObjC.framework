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

@implementation MEOImageDownloader

+ (void)imageUrl:(NSString*)imageUrl
      completion:(MEOImageDownloaderCompletion)completion
{
    MEOApiOption *option = [[MEOApiOption alloc] init];
    option.comparelastModified = true;
    [MEOImageDownloader imageUrl:imageUrl
                          option:option
                      completion:completion];
}


+ (void)imageUrl:(NSString*)imageUrl
          option:(MEOApiOption*)option
      completion:(MEOImageDownloaderCompletion)completion
{
    BOOL comparelastModified = false;
    if (option) {
        comparelastModified = option.comparelastModified;
    }
    
    if (imageUrl && imageUrl.length > 0) {
        MEOCache *cache = [MEOCacheManager cacheForKey:imageUrl];
        UIImage *cachedImage = cache.image;
        
        if (cachedImage) {
            
            if (comparelastModified == false) {
                if (completion) {
                    completion(cachedImage, true);
                }
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
                     if (cache.updatedAt
                         && lastModified
                         && [cache.updatedAt compare:lastModified] == NSOrderedAscending) {
 
                         // 古いので更新する
                         [MEOApiManager download:imageUrl
                                          option:option
                                      completion:^(MEOApiManagerResultStatus result,
                                                   NSData *data,
                                                   NSDictionary *userInfo,
                                                   NSInteger httpStatus,
                                                   NSError *error)
                          {
                              UIImage *image = nil;
                              if (error == nil) {
                                  UIImage *image = [[UIImage alloc] initWithData:data];
                                  if (image) {
                                      [MEOCacheManager setImage:image forKey:imageUrl];
                                  }
                              }
                              if (completion) {
                                  completion(image, false);
                              }
                          }];
                     }else{
                         if (completion) {
                             completion(cachedImage, true);
                         }
                     }
                 }];
            }
            
        }else {
            [MEOApiManager download:imageUrl
                             option:nil
                         completion:^(MEOApiManagerResultStatus result,
                                      NSData *data,
                                      NSDictionary *userInfo,
                                      NSInteger httpStatus,
                                      NSError *error)
             {
                 UIImage *image = nil;
                 if (error == nil) {
                     image = [[UIImage alloc] initWithData:data];
                     if (image) {
                         [MEOCacheManager setImage:image forKey:imageUrl];
                     }
                 }
                 if (completion) {
                     completion(image, false);
                 }
             }];
        }
    }else{
        if (completion) {
            completion(nil, false);
        }
    }
}

@end
