//
//  NSString+Enhanced.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/04/11.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSString (NSDate)

- (NSDate*)dateUsingStrptimeWithFormatAtJST:(NSString*)format;
- (NSDate*)dateUsingStrptimeWithFormat:(NSString*)format timeZone:(NSTimeZone*)timeZone;

@end

@interface NSString (Enhanced)

-(NSString*)trim;

-(NSString*)encodeUrlString;
-(NSString*)decodeUrlString;
-(NSDictionary*)dictionaryFromQueryString;

-(BOOL)isEmail;

+(NSString*)uuid;
+(NSString*)comfirm:(NSString*)string;
+(BOOL)isString:(NSString*)obj;

// 数値を三桁のコンマ区切りの文字列に変換する
+(NSString*)priceString:(NSInteger)price;

-(NSArray*)parsedByLines;

// 数字だけを取りだす
-(NSString*)extractedIntegerString;

-(NSArray*)detectedUrls;

-(CGRect)drawnRectWithSize:(CGSize)size font:(UIFont*)font;
-(CGSize)sizeWithFontAboveiOS7:(UIFont *)font;

// 半角カタカナに変換
- (NSString *)halfKana;

// ランダム文字列（小文字）
+ (NSString *)randomStringWithLength:(NSUInteger)len;

-(NSString*)md5;

@end

@interface NSString (SHA256)
-(NSString*)SHA256;
@end
