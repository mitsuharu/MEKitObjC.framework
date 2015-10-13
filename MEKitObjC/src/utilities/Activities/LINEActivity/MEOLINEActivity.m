//
//  MEOLINEActivity.m
//

#import "MEOLINEActivity.h"
#import "MEOUtilities.h"

NSString *const MEOActivityTypeLINE = @"jp.naver.LINEActivity";

@implementation MEOLINEActivity

+ (BOOL)canOpenLINE
{
    NSURL *instagramURL = [NSURL URLWithString:@"line://"];
    BOOL result =  [[UIApplication sharedApplication] canOpenURL:instagramURL];
    return result;
}

- (NSString *)activityType {
    return MEOActivityTypeLINE;
}

- (UIImage *)activityImage
{
    UIImage *image = [MEOUtilities imageOfResourceBundle:@"LINEActivityIcon"];
    return image;
}

- (NSString *)activityTitle
{
    return @"LINE";
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    BOOL result = [MEOLINEActivity canOpenLINE];
    if (result == false) {
        return false;
    }
    
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[NSString class]] || [activityItem isKindOfClass:[UIImage class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[UIImage class]]) {
            if ([self openLINEWithItem:activityItem]) {
                return;
            }
        }
    }
    
    for (id activityItem in activityItems) {
        if ([self openLINEWithItem:activityItem]){
            break;
        }
    }
}

- (BOOL)isUsableLINE
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"line://"]];
}

- (void)openLINEOnITunes
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/jp/app/line/id443904275?ls=1&mt=8"]];
}

- (BOOL)openLINEWithItem:(id)item
{
    if (![self isUsableLINE]) {
        [self openLINEOnITunes];
        return NO;
    }
    
    NSString *LINEURLString = nil;
    if ([item isKindOfClass:[NSString class]]) {
		item = [(NSString *)item stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        LINEURLString = [NSString stringWithFormat:@"line://msg/text/%@", item];
    } else if ([item isKindOfClass:[UIImage class]]) {
        UIPasteboard *pasteboard =  [UIPasteboard generalPasteboard];
        // http://d.hatena.ne.jp/s-0samu/20140323/1395552188
        [pasteboard setData:UIImagePNGRepresentation(item) forPasteboardType:@"public.png"];
        LINEURLString = [NSString stringWithFormat:@"line://msg/image/%@", pasteboard.name];
    } else {
        return NO;
    }
    
    NSURL *LINEURL = [NSURL URLWithString:LINEURLString];
    [[UIApplication sharedApplication] openURL:LINEURL];
    return YES;
}

@end
