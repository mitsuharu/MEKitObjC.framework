//
//  MEOWebViewController.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/04/09.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^MEOWebViewControllerErrorCompletion)(NSError *error);

@interface MEOWebViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) NSString *htmlString;

@property (nonatomic, retain) UIBarButtonItem *reloadItem;
@property (nonatomic, retain) UIBarButtonItem *forwardItem;
@property (nonatomic, retain) UIBarButtonItem *backItem;

@property (nonatomic, retain) UIButton *reloadButton;
@property (nonatomic, retain) UIButton *forwardButton;
@property (nonatomic, retain) UIButton *backButton;

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;

@property (nonatomic, copy) MEOWebViewControllerErrorCompletion blockNetworkFailed;
@property (nonatomic, copy) MEOWebViewControllerErrorCompletion blockWebviewFailed;

-(IBAction)doReloadWebview:(id)sender;
-(IBAction)doForwardWebview:(id)sender;
-(IBAction)doBackWebview:(id)sender;



@end
