//
//  MEOUtilities.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2014/10/30.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOUtilities.h"
#import <UIKit/UIKit.h>

NSString *const kResourceBundleName = @"MEKitObjCResources";

@interface MEOUtilities ()
{
}
@end

@implementation MEOUtilities

//
// see http://paulsolt.com/2012/12/resource-bundles-for-iphone-frameworks-and-static-libraries/
//
+(UIImage*)imageOfResourceBundle:(NSString*)name
{
    NSString *imageName = nil;
    NSString *png = @".png";
    if ([name hasSuffix:png]) {
        imageName = [name substringWithRange:NSMakeRange(0, name.length - png.length)];
    }else{
        imageName = name;
    }
    
    UIImage *image = nil;
    if ([UIImage resolveClassMethod:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        image = [UIImage imageNamed:imageName
                           inBundle:[MEOUtilities resourceBundle]
      compatibleWithTraitCollection:nil];
    }else{
        NSString *nameBundled = [NSString stringWithFormat:@"%@.bundle/%@.png", kResourceBundleName, imageName];
        image = [UIImage imageNamed:nameBundled];
    }
    
    if (image == nil) {
        NSString *imagePath = [[MEOUtilities resourceBundle] pathForResource:imageName
                                                                      ofType:@"tiff"];
        if (imagePath) {
            image = [UIImage imageWithContentsOfFile:imagePath];
        }
    }
    
    return image;
}

+(NSBundle*)resourceBundle
{
    NSString *path = [[NSBundle mainBundle] pathForResource:kResourceBundleName ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    return bundle;
}

+(NSString*)localizedString:(NSString*)key{
    return [MEOUtilities localizedString:key comment:key];
}


+(NSString*)localizedString:(NSString*)key comment:(NSString*)comment
{
    NSBundle *bundle = [MEOUtilities resourceBundle];
    
    NSString *str = (comment!=nil)?(comment):(key);
    if (bundle) {
        str = [bundle localizedStringForKey:key
                                      value:comment
                                      table:nil];
    }

    return str;
}


//internal class func ios7over() -> Bool{
//    
//    //        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1 ){
//    //            //Here goes the code for iOS 7
//    //        }
//    //        else if (NSFoundationVersionNumber == NSFoundationVersionNumber_iOS_6_1){
//    //            //Here goes the code for iOS 6.1
//    //        }
//    
//    return NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0
//}

//class func isJapaneseLang() -> Bool
//{
//    var langs = NSLocale.preferredLanguages();
//    var current:String = langs.first as String;
//    var isJa:Bool = (current.compare("ja") == NSComparisonResult.OrderedSame);
//    return isJa;
//}


@end
