//
//  MEOInstagramActivity.m
//
//  Created by Mitsuharu Emoto on 2015/09/14.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOInstagramActivity.h"
#import "MEOUtilities.h"

@interface MEOInstagramActivity ()
<
    UIDocumentInteractionControllerDelegate
>

@property (nonatomic) NSString *text;
@property (nonatomic) NSURL *url;
@property (nonatomic) UIImage *image;
@property (nonatomic) UIDocumentInteractionController *documentInteractionController;

@end

@implementation MEOInstagramActivity

- (NSString *)activityType
{
    return @"UIActivityTypePostToInstagram";
}

- (NSString *)activityTitle
{
    return @"Instagram";
}

- (UIImage *)activityImage
{
    UIImage *image = [MEOUtilities imageOfResourceBundle:@"instagram"];
    return image;
}


- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if (![[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        NSLog(@"no instagram");
        return false;
    }
    for (UIActivityItemProvider *item in activityItems) {
        if ([item isKindOfClass:[UIImage class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    NSMutableArray *strArray = [[NSMutableArray alloc] initWithCapacity:1];
    NSMutableArray *urlArray = [[NSMutableArray alloc] initWithCapacity:1];
    for (id item in activityItems){
        if ([item isKindOfClass:[UIImage class]]) {
            self.image = item;
        }
        if ([item isKindOfClass:[NSString class]]) {
            [strArray addObject:item];
        }
        if ([item isKindOfClass:[NSURL class]]) {
            NSURL *url = (NSURL*)item;
            [urlArray addObject:url.absoluteString];
        }
    }
    
    if (urlArray.count > 0) {
        [strArray addObjectsFromArray:urlArray];
    }
    
    if (strArray.count > 0) {
        self.text = [strArray componentsJoinedByString:@", "];
    }

    CGFloat minSize = 640;
    if (self.image
        && self.image.size.width < minSize && self.image.size.height < minSize) {
        self.image = [MEOInstagramActivity resizedImage:self.image
                                                   size:CGSizeMake(minSize, minSize)];
    }
}


- (void)performActivity
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *saveImagePath = [cachesDirectory stringByAppendingPathComponent:@"Image.igo"];
    NSData *imageData = UIImagePNGRepresentation(self.image);
    [imageData writeToFile:saveImagePath atomically:YES];
    
    NSURL *imageURL = [NSURL fileURLWithPath:saveImagePath];

    self.documentInteractionController = [[UIDocumentInteractionController alloc]init];
    self.documentInteractionController.delegate = self;
    self.documentInteractionController.UTI = @"com.instagram.photo";
    [self.documentInteractionController setURL:imageURL];
    
    if (self.text) {
        self.documentInteractionController.annotation = @{@"InstagramCaption":self.text};
    }
    
    UIViewController *vc = [MEOInstagramActivity viewController];
    BOOL present = [self.documentInteractionController presentOpenInMenuFromRect:vc.view.frame
                                                                          inView:vc.view
                                                                        animated:true];
    
    if (!present) {
        NSLog(@"このファイルを開けるアプリが存在しない。");
    }
//    [self activityDidFinish:true];
}

+(UIViewController*)viewController
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *vc = window.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    return vc;
}

+ (UIImage *)resizedImage:(UIImage *)image size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    [image drawInRect:CGRectMake(0.0, 0.0, size.width, size.height)];
    
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    [self activityDidFinish:true];
}

@end
