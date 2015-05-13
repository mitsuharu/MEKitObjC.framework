//
//  MEODownloader.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/01/11.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import "MEODownloader.h"

@interface MEODownloader() < NSURLConnectionDelegate  >
{
    NSString *urlString_;
    NSMutableData *responseData_;
    NSURLConnection *urlConnection_;
    NSError *error_;
    BOOL finished_;
    MEODownloaderCompletion completion_;
    id userInfo_;
    id<MEODownloaderDelegate> delegate_;
}

@end

@implementation MEODownloader

@synthesize urlString = urlString_;
@synthesize responseData = responseData_;
@synthesize delegate = delegate_;
@synthesize userInfo = userInfo_;
@synthesize completion =  completion_;
@synthesize finished = finished_;

-(id)init
{
    if (self = [super init]) {
        urlString_ = nil;
        responseData_ = nil;
        userInfo_ = nil;
        error_ = nil;
        delegate_ = nil;
        completion_ = nil;
        finished_ = NO;
    }
    return self;
}

-(void)dealloc
{
    urlString_ = nil;
    responseData_ = nil;
    userInfo_ = nil;
    error_ = nil;
    delegate_ = nil;
    completion_ = nil;
    finished_ = NO;
}

-(UIImage*)imageFromResponseData
{
    UIImage *img = nil;
    if (responseData_) {
        img = [UIImage imageWithData:responseData_];
    }
    return img;
}

-(void)start
{
    [self start:urlString_];
}

-(void)start:(NSString*)urlString
{
    if (!urlString || urlString.length == 0) {
        if (delegate_ && [delegate_ respondsToSelector:@selector(doMEODownloaderFailed:)]) {
            [delegate_ doMEODownloaderFailed:self];
        }
        return;
    }
    
    error_ = nil;
    urlString_ = [[NSString alloc] initWithString:urlString];
    responseData_ = [NSMutableData dataWithCapacity:1];
    
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString_]];
    urlConnection_ = [[NSURLConnection alloc] initWithRequest:urlRequest
                                                     delegate:self];
    if (urlConnection_) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }else{
        
        responseData_ = nil;
        finished_ = NO;
        
        if (delegate_ && [delegate_ respondsToSelector:@selector(doMEODownloaderFailed:)]) {
            [delegate_ doMEODownloaderFailed:self];
        }
        
        if (completion_) {
            __block MEODownloader *dl = self;
            completion_(dl);
        }
        
    }
}

-(void)cancel
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (urlConnection_) {
        [urlConnection_ cancel];
        urlConnection_ = nil;
        responseData_ = nil;
        error_ = nil;
        finished_ = NO;
    }
    
    if (delegate_ && [delegate_ respondsToSelector:@selector(doMEODownloaderFailed:)]) {
        [delegate_ doMEODownloaderFailed:self];
    }
    
    if (completion_) {
        __block MEODownloader *dl = self;
        completion_(dl);
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [responseData_ setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData_ appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [connection cancel];
    responseData_ = nil;
    error_ = error;
    finished_ = NO;
    
    if (delegate_ && [delegate_ respondsToSelector:@selector(doMEODownloaderFailed:)]) {
        [delegate_ doMEODownloaderFailed:self];
    }
    
    if (completion_) {
        __block MEODownloader *dl = self;
        completion_(dl);
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    error_ = nil;
    
    if (responseData_) {
        finished_ = YES;
        if (delegate_ && [delegate_ respondsToSelector:@selector(doMEODownloaderFinished:data:)]) {
            [delegate_ doMEODownloaderFinished:self data:responseData_];
        }
    }else{
        finished_ = NO;
        if (delegate_ && [delegate_ respondsToSelector:@selector(doMEODownloaderFailed:)]) {
            [delegate_ doMEODownloaderFailed:self];
        }
    }
    
    if (completion_) {
        __block MEODownloader *dl = self;
        completion_(dl);
    }
}


@end
