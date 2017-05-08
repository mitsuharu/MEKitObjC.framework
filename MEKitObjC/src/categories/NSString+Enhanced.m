//
//  NSString+Enhanced.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/04/11.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import "NSString+Enhanced.h"

#import <CommonCrypto/CommonDigest.h>
#import <mach/mach_time.h>
#import <time.h>
#import <xlocale.h>

@implementation NSString (localized)

NSString *meo_localizedString(NSString *key)
{
    return NSLocalizedStringFromTable(key, nil, nil);
}

+ (NSString*)meo_localized:(NSString*)key
{
    return [NSString meo_localized:key tableName:nil];
}

+ (NSString*)meo_localized:(NSString*)key tableName:(NSString *)tableName;
{
    return NSLocalizedStringFromTable(key, tableName, nil);
}

@end


@implementation NSString (NSDate)

- (NSDate*)dateUsingStrptimeWithFormatAtJST:(NSString*)format
{
    struct tm time;
    const char *formatChar = [format UTF8String];
    strptime_l([self UTF8String], formatChar, &time, NULL);
    
    NSTimeInterval t = timegm(&time);
    
    // timezone を解釈してくれないので手動補正
    t -= 32400;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: t];
    
    return date;
}

- (NSDate*)dateUsingStrptimeWithFormat:(NSString*)format timeZone:(NSTimeZone*)timeZone
{
    struct tm time;
    const char *formatChar = [format UTF8String];
    strptime_l([self UTF8String], formatChar, &time, NULL);
    
    NSTimeInterval t = timegm(&time);
    
    // timezone を解釈してくれないので手動補正
    if(timeZone) {
        t -= [timeZone secondsFromGMT];
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: t];
    
    return date;
}
@end


@implementation NSString (Enhanced)

-(NSString*)trim
{
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *string = [self stringByTrimmingCharactersInSet:characterSet];
    return string;
}

-(CGRect)drawnRectWithSize:(CGSize)size font:(UIFont*)font
{
    return [self rectWithDrawnSize:size font:font];
}

-(CGRect)rectWithDrawnSize:(CGSize)size font:(UIFont*)font
{
    @try {
        NSDictionary *attributes = @{NSFontAttributeName:font};
     CGRect rect = [self boundingRectWithSize:CGSizeMake(size.width, FLT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attributes
                                         context:nil];
        return rect;
        
    }
    @catch (NSException *exception) {
        return CGRectMake(0, 0, size.width, size.height);
    }
    @finally {
    }
}

-(CGSize)sizeWithDrawnSize:(CGSize)size font:(UIFont*)font
{
    CGRect rect = [self rectWithDrawnSize:size font:font];
    return CGSizeMake(ceilf(CGRectGetWidth(rect)), ceilf(CGRectGetHeight(rect)));
}

-(CGSize)sizeWithFontAboveiOS7:(UIFont *)font
{
    CGSize size = CGSizeZero;
    if (font) {
        NSDictionary *attributes = @{NSFontAttributeName:font};
        size = [self sizeWithAttributes:attributes];
    }
    return size;
}


// 数値を三桁のコンマ区切りの文字列に変換する
+(NSString*)priceString:(NSInteger)price
{
    NSNumber *priceNumber = [[NSNumber alloc] initWithInteger:price];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSeparator:@","];
    [formatter setGroupingSize:3];
    
    NSString *priceStr = [formatter stringFromNumber:priceNumber];
    return priceStr;
}



// 数字だけを取りだす
-(NSString*)extractedIntegerString
{
    NSString *str = [NSString string];

    if (self && self.length > 0) {
        // http://qiita.com/yusuga_/items/b2acd89a98bd47b1429f
        
        NSMutableString *scannedStr = [NSMutableString string];
        
        NSScanner *scanner = [NSScanner scannerWithString:self];
        [scanner setCharactersToBeSkipped:[NSCharacterSet letterCharacterSet]];
        while (scanner.isAtEnd == NO) {
            NSInteger i;
            [scanner scanInteger:&i];
            [scannedStr appendFormat:@"%ld", (long)i];
        }
        
        str = [[NSString alloc] initWithString:scannedStr];
    }
    
    
    return str;
}



-(NSString*)encodeUrlString
{
    NSString *str = nil;
    if ([self respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        str = [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    }else{
        str = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                    NULL,
                                                                                    (CFStringRef)self,
                                                                                    NULL,
                                                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                    kCFStringEncodingUTF8 ));
    }
    
    return str;
}

-(NSString*)decodeUrlString
{
    NSString *str = nil;
    if ([self respondsToSelector:@selector(stringByRemovingPercentEncoding)]) {
        str = [self stringByRemovingPercentEncoding];
    }else{
        str = (NSString *) CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                     (CFStringRef)self,
                                                                                                     CFSTR(""),
                                                                                                     kCFStringEncodingUTF8));
    }
    
    return str;
}

-(NSDictionary*)dictionaryFromQueryString
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    NSArray *params = [self componentsSeparatedByString:@"&"];
    for (NSString *param in params) {
        NSArray *keyValue = [param componentsSeparatedByString:@"="];
        
        // has not key and value
        if(!keyValue || 0 == [keyValue count]) {
            continue;
        }
        
        //// key
        NSString *key = [keyValue[0] decodeUrlString];
        
        //// value
        NSString *value = @"";
        // if has value
        if(2 <= [keyValue count]) {
            if(keyValue[1]) {
                value = [keyValue[1] decodeUrlString];
            }
        }
        
        // set to dictionary
        [dictionary setObject:value forKey:key];
    }
    
    return dictionary;
}

- (CGSize)meoSizeWithSystemFontSize:(CGFloat)fontSize constrainedToSize:(CGSize)size
{
    return [self meoSizeWithFont:[UIFont systemFontOfSize:fontSize]
               constrainedToSize:size];
}

- (CGSize)meoSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size
{
    CGSize size2 = CGSizeMake(0, 0);
    NSDictionary *attributeDict = @{NSFontAttributeName:font};
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine;

    for (NSString *str in [self parsedByLines]) {
        
        CGFloat tempHeight = 0;
        if (str.length == 0){
            CGRect rect = [@"a" boundingRectWithSize:CGSizeMake(size.width, CGFLOAT_MAX)
                                            options:options
                                         attributes:attributeDict
                                            context:nil];
            tempHeight = CGRectGetHeight(rect);
        }else{
            CGRect rect = [str boundingRectWithSize:CGSizeMake(size.width, CGFLOAT_MAX)
                                            options:options
                                         attributes:attributeDict
                                            context:nil];
            if (size2.width < ceilf(rect.size.width)){
                size2.width = ceilf(rect.size.width);
            }
            tempHeight = CGRectGetHeight(rect);
        }
        size2.height += tempHeight;
    }
    size2.height = ceilf(size2.height);
    
    return size2;
}

-(NSArray*)parsedByLines
{
    NSMutableArray *mlines = [NSMutableArray array];
    [self enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        [mlines addObject:line];
    }];
    
    NSArray *temp = [self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    if (temp.count > 1 && [temp.lastObject isEqualToString:@""]){
        [mlines addObject:temp.lastObject];
    }
    
    NSArray *lines = [mlines copy];
    mlines = nil;
    
    return lines;
    
//    return [self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}


-(NSArray*)detectedUrls
{
    NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                                   error:nil];
    NSArray *results = [dataDetector matchesInString:self
                                             options:0
                                               range:NSMakeRange(0,[self length])];
    
    NSMutableArray *urls = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSTextCheckingResult *result in results){
        if ([result resultType] == NSTextCheckingTypeLink){
            NSURL *url = [result URL];
            [urls addObject:[url absoluteString]];
        }
    }
    
    return (NSArray*)urls;
}


-(BOOL)isEmail
{
    BOOL email = NO;
    
    NSError *error = nil;
    NSString *pattern = @"[\\w\\.\\-]+@(?:[\\w\\-]+\\.)+[\\w\\-]+";
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                            options:0
                                                                              error:&error];
    if (!error) {
        NSArray *arr = [regexp matchesInString:self
                                       options:0
                                         range:NSMakeRange(0, self.length)];
        if (arr.count == 0) {
            email = NO;
        }else{
            email = YES;
        }
    }
    return email;
}

+(NSString*)uuid
{
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    return uuidString;
}

+(NSString*)comfirm:(NSString*)string
{
    NSString *str = @"";
    if (string && [string isKindOfClass:[NSString class]] && string.length > 0) {
        str = string;
    }
    return str;
}

+(BOOL)isString:(NSString*)string
{
    BOOL str = NO;
    if (string && [string isKindOfClass:[NSString class]] && string.length > 0) {
        str = YES;
    }
    return str;
}

- (NSString *)halfKana
{
    NSString *str = [self copy];
    if (str && str.length > 0) {
        NSMutableString *mstr = [str mutableCopy];
        CFStringTransform((CFMutableStringRef)mstr, NULL, kCFStringTransformHiraganaKatakana, NO);
        CFStringTransform((CFMutableStringRef)mstr, NULL, kCFStringTransformFullwidthHalfwidth, NO);
        str = mstr;
    }
    return str;
}

+ (NSString *)randomStringWithLength:(NSUInteger)len {
    
//    NSArray *characters = [[NSCharacterSet lowercaseLetterCharacterSet] allObjects];
    NSString *characters = @"abcdefghijklmnopqrstuvwxyz0123456789";
    
    NSMutableString *string = [NSMutableString stringWithCapacity:len];
    for (NSUInteger i = 0; i < len; i++) {
        u_int32_t r = arc4random_uniform((u_int32_t)[characters length]);
        NSString *s = [characters substringWithRange:NSMakeRange(r, 1)];
        [string appendFormat:@"%@", s];
    }
    return [NSString stringWithString:string];
}


-(NSString *)md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end


@implementation NSString (SHA256)

- (NSString*)SHA256
{
    const char *str = [self UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, (CC_LONG) strlen(str), result);
    
    NSMutableString *hash = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for ( int i=0; i<CC_SHA256_DIGEST_LENGTH; i++ ) {
        [hash appendFormat:@"%02x",result[i]];
    }
    
    return hash;
}
@end
