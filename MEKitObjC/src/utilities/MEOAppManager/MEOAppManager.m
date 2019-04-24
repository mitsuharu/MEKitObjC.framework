//
//  MEOAppManager.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2014/11/19.
//  Copyright (c) 2014年 Mitsuharu Emoto. All rights reserved.
//

#import "MEOAppManager.h"

@interface NSString (private)
-(NSString*)encodeUrlString;
@end

@implementation NSString (private)

-(NSString*)encodeUrlString
{
    NSString *str = nil;
    if ([self respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        str = [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    }
    return str;
}

@end


@interface MEOAppManager (private)
+(NSString*)xCallbackUrlParameter;
@end

@implementation MEOAppManager (private)

+(NSString*)xCallbackUrlParameter
{
    NSString *name = [MEOAppManager appName];
    NSString *scheme = [MEOAppManager appScheme];
    NSString *str = nil;
    if (name.length >0 && scheme.length > 0) {
        str = [NSString stringWithFormat:@"x-success=%@&x-source=%@", scheme, name];
    }
    return str;
}

@end

@implementation MEOAppManager

+(NSString*)appScheme
{
    NSString *scheme = nil;
    NSBundle *bundle = [NSBundle mainBundle];
    
    NSDictionary *infoDict = [bundle infoDictionary];
    NSDictionary *urlDict = nil;
    if ([infoDict.allKeys containsObject:@"CFBundleURLTypes"]) {
         NSArray *urlArr = [infoDict valueForKey:@"CFBundleURLTypes"];
        urlDict = [urlArr objectAtIndex:0];
    }
    
    if (urlDict && [urlDict.allKeys containsObject:@"CFBundleURLSchemes"]) {
        NSArray *schemeArr = [urlDict valueForKey:@"CFBundleURLSchemes"];
        scheme = [schemeArr objectAtIndex:0];
    }
    
    NSRange range = [scheme rangeOfString:@"://"];
    if (range.location == NSNotFound) {
        scheme = [NSString stringWithFormat:@"%@://", scheme];
    }
    
    return scheme;
}

+(NSString*)appName
{
    NSString *name = @"App";
    NSBundle *bundle = [NSBundle mainBundle];
    
    NSString *locaizedName = nil;
    NSDictionary *localizedDict = [bundle localizedInfoDictionary];
    NSDictionary *infoDict = [bundle infoDictionary];
    
    if (localizedDict) {
        NSString *str = [localizedDict objectForKey:@"CFBundleDisplayName"];
        if (str == nil || str.length == 0) {
            str = [localizedDict objectForKey:@"CFBundleName"];
        }
        if (str && str.length > 0) {
            locaizedName = str;
        }
    }
    
    if (locaizedName && locaizedName.length > 0) {
        name = locaizedName;
    }else{
        NSString *str = [infoDict objectForKey:@"CFBundleDisplayName"];
        if (str == nil || str.length == 0) {
            str = [infoDict objectForKey:@"CFBundleName"];
        }
        if (str && str.length > 0) {
            name = str;
        }
    }
    
    return name;
}

+(BOOL)openApp:(NSString*)urlScheme {
    return [MEOAppManager openApp:urlScheme completion:nil];
}

+(BOOL)openApp:(NSString*)urlScheme completion:(void (^)(BOOL success))completion
{
    NSURL *url = [NSURL URLWithString:urlScheme];
    UIApplication *app = [UIApplication sharedApplication];
    if ([app canOpenURL:url]) {
        [app openURL:url options:@{} completionHandler:^(BOOL success) {
            if (completion){
                completion(success);
            }
        }];
        return true;
    }else{
        if (completion){
            completion(false);
        }
        return false;
    }
}

+(BOOL)openMapsApp:(NSString*)target
{
    BOOL result = false;

    NSString *gcScheme = @"comgooglemaps-x-callback://";
    NSString *gmScheme = @"comgooglemaps://";
    NSString *amScheme = @"http://maps.apple.com/";
    NSString *xCallbackPrm = [MEOAppManager xCallbackUrlParameter];
    
    UIApplication *app = [UIApplication sharedApplication];
    if ([app canOpenURL:[NSURL URLWithString:gcScheme]] && xCallbackPrm)
    {
        NSString *prm0 = [NSString stringWithFormat:@"q=%@&zoom=14", [target encodeUrlString]];
        NSString *prm1 = xCallbackPrm;
        NSString *scheme = [NSString stringWithFormat:@"%@?%@&%@", gcScheme, prm0, prm1];
        result = [app openURL:[NSURL URLWithString:scheme]];
    }else if ([app canOpenURL:[NSURL URLWithString:gmScheme]])
    {
        NSString *prm0 = [NSString stringWithFormat:@"q=%@&zoom=14", [target encodeUrlString]];
        NSString *scheme = [NSString stringWithFormat:@"%@?%@", gmScheme, prm0];
        result = [app openURL:[NSURL URLWithString:scheme]];
    }else if ([app canOpenURL:[NSURL URLWithString:amScheme]])
    {
        NSString *prm0 = [NSString stringWithFormat:@"q=%@", [target encodeUrlString]];
        NSString *scheme = [NSString stringWithFormat:@"%@?%@", amScheme, prm0];
        result = [app openURL:[NSURL URLWithString:scheme]];
    }
    
    return result;
}


@end
