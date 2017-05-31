//
//  NSString+Enhanced.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/04/11.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSString (localized)

/**
 ローカライズ文字列を取得する
 @param key ローカライズのキー
 @return keyに対応したローカライズされた文字列．もし無ければkeyが返る
 */
NSString *meo_localizedString(NSString *key);

/**
 ローカライズテーブル``Localizable.strings``からローカライズ文字列を取得する
 @param key ローカライズのキー
 @return keyに対応したローカライズされた文字列．もし無ければkeyが返る
 */
+ (NSString*)meo_localized:(NSString*)key;

/**
 ローカライズ文字列を取得する
 @param key ローカライズのキー
 @param tableName ローカライズのテーブル名(例：Localizable)
 @return keyに対応したローカライズされた文字列．もし無ければkeyが返る
 */
+ (NSString*)meo_localized:(NSString*)key tableName:(NSString *)tableName;

@end

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

/**
 *  改行ごとに文字列を分解する
 */
-(NSArray*)parsedByLines;

/**
 *  文字列の描画サイズを計算する
 *
 *  @param font フォント
 *  @param size （例）CGSizeMake(width, CGFLOAT_MAX)
 *
 *  @return 描画サイズ
 */
- (CGSize)meoSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

/**
 *  文字列の描画サイズを計算する
 *
 *  @param fontSize フォントサイズ
 *  @param size     （例）CGSizeMake(width, CGFLOAT_MAX)
 *
 *  @return 描画サイズ
 */
- (CGSize)meoSizeWithSystemFontSize:(CGFloat)fontSize constrainedToSize:(CGSize)size;


// 数字だけを取りだす
-(NSString*)extractedIntegerString;

-(NSArray*)detectedUrls;

/**
 *  文字列の描画サイズを計算する
 */
-(CGRect)drawnRectWithSize:(CGSize)size font:(UIFont*)font __attribute__((deprecated("use meoSizeWithFont:constrainedToSize:")));

/**
 *  文字列の描画サイズを計算する
 */
-(CGRect)rectWithDrawnSize:(CGSize)size font:(UIFont*)font __attribute__((deprecated("use meoSizeWithFont:constrainedToSize:")));

/**
 *  文字列の描画サイズを計算する
 */
-(CGSize)sizeWithDrawnSize:(CGSize)size font:(UIFont*)font __attribute__((deprecated("use meoSizeWithFont:constrainedToSize:")));

/**
 *  文字列の描画サイズを計算する
 */
-(CGSize)sizeWithFontAboveiOS7:(UIFont *)font __attribute__((deprecated("use meoSizeWithFont:constrainedToSize:")));

// 半角カタカナに変換
- (NSString *)halfKana;

// ランダム文字列（小文字）
+ (NSString *)randomStringWithLength:(NSUInteger)len;

-(NSString*)md5;


- (double)hexToDouble;

@end

@interface NSString (SHA256)
-(NSString*)SHA256;
@end
