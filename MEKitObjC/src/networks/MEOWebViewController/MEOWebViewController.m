//
//  MEOWebViewController.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/04/09.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOWebViewController.h"
#import "MEOSystemStatus.h"

@interface MEOWebViewController () < UIWebViewDelegate >
{
    NSURLRequest *request_;
}

-(void)updateButtonStates;
-(void)showNetworkIndicator:(BOOL)show;

@end

@implementation MEOWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.webView) {
        [self updateButtonStates];
        
        if (self.htmlString.length > 0){
            [self.webView loadHTMLString:self.htmlString baseURL:nil];
            [self updateButtonStates];
        }else if (self.urlString.length > 0) {
            BOOL reachabile = [MEOSystemStatus reachabile];
            if (reachabile) {
                NSURL *url = [NSURL URLWithString:self.urlString];
                request_ = [NSURLRequest requestWithURL:url];
                self.webView.scalesPageToFit = YES;
                [self.webView loadRequest:request_];
                [self updateButtonStates];
            }else{
                if (self.blockNetworkFailed) {
                    self.blockNetworkFailed(nil);
                }
                [self showNetworkIndicator:true];
            }
        }
        
        self.webView.delegate = self;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.webView
        && self.urlString.length > 0
        && [MEOSystemStatus reachabile] == false) {
        if (self.blockNetworkFailed) {
            self.blockNetworkFailed(nil);
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self showNetworkIndicator:false];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - newwork indicator

-(void)showNetworkIndicator:(BOOL)show
{
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = show;
}


#pragma mark - buttons

-(void)updateButtonStates
{
    if (self.webView) {
        if (self.backButton) {
            self.backButton.enabled = [self.webView canGoBack];
        }
        if (self.backItem) {
            self.backItem.enabled = [self.webView canGoBack];
        }
        if (self.forwardButton) {
            self.forwardButton.enabled = [self.webView canGoBack];
        }
        if (self.forwardItem) {
            self.forwardItem.enabled = [self.webView canGoBack];
        }
    }
}

-(IBAction)doReloadWebview:(id)sender
{
    if (self.webView) {
        
        if (request_ == nil && self.urlString.length > 0) {
            
            if ( [MEOSystemStatus reachabile] == false) {
                if (self.blockNetworkFailed) {
                    self.blockNetworkFailed(nil);
                }
            }else{
                NSURL *url = [NSURL URLWithString:self.urlString];
                request_ = [NSURLRequest requestWithURL:url];
                self.webView.scalesPageToFit = YES;
                [self.webView loadRequest:request_];
            }
        }else{
            [self.webView reload];
            
        }
        
        [self updateButtonStates];
    }
}

-(IBAction)doForwardWebview:(id)sender
{
    if (self.webView && [self.webView canGoForward]) {
        [self.webView goForward];
        [self updateButtonStates];
    }
}

-(IBAction)doBackWebview:(id)sender
{
    if (self.webView && [self.webView canGoBack]) {
        [self.webView goBack];
        [self updateButtonStates];
    }
}

#pragma mark - UIWebViewDelegate

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showNetworkIndicator:true];
    [self updateButtonStates];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self showNetworkIndicator:false];
    [self updateButtonStates];
}


-(BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL result = YES;
    if([request valueForHTTPHeaderField:@"Authorization"]){
        result = YES;
    }else if (self.username.length > 0 && self.password.length > 0) {
        NSMutableURLRequest *req = (NSMutableURLRequest*)request;
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", self.username, self.password];
        NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
        
        NSString *base64 = nil;
        if ([authData respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
            base64 = [authData base64EncodedStringWithOptions:0];
        }else if ([authData respondsToSelector:@selector(base64Encoding)]){
            base64 = [authData base64Encoding];
        }
        
        NSString *basicValue = [NSString stringWithFormat:@"Basic %@", base64];
        [req addValue:basicValue forHTTPHeaderField:@"Authorization"];
        [webView loadRequest:req];
        
        result = NO;
    }

    return result;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (self.urlString.length > 0) {
        [self showNetworkIndicator:false];
    }
    [self updateButtonStates];
    
    
    if (self.urlString.length > 0 && [MEOSystemStatus reachabile] == false) {
        if (self.blockNetworkFailed) {
            self.blockNetworkFailed(nil);
        }
    }else if (error) {
        if (self.blockWebviewFailed) {
            self.blockWebviewFailed(error);
        }
    }
}


@end
