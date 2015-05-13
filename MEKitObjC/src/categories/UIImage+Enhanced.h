//
//  UIImage+Enhanced.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/06/25.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Enhanced)

-(UIImage*)imageResizedAspectFit:(CGSize)size;
-(UIImage*)imageResizedScaleToFill:(CGSize)size;


-(UIImage*)resizedImage:(CGSize)size;
-(CGFloat)mbytePng;

+(UIImage*)imageWithString:(NSString *)text
                      size:(CGSize)size
                      font:(UIFont*)font
                 fontColor:(UIColor*)fontColor
                 backColor:(UIColor*)backColor;

+(UIImage*)imageCircleWithRadius:(CGFloat)radius
                           color:(UIColor*)color;

+(UIImage*)imageCircleWithRadius:(CGFloat)radius
                           color:(UIColor*)color
                     borderWidth:(CGFloat)borderWidth
                     borderColor:(UIColor*)borderColor;


-(UIImage*)rasterizedImage:(CGFloat)rasterizationScale;

@end

@interface UIImage (Colorway)

//
// 1つの画像から色違い画像を作る
//

+(UIImage*)image:(UIImage*)aImage colored:(UIColor*)aColor;
+(UIImage*)image:(UIImage*)aImage tintColored:(UIColor*)aTintColor;
+(UIImage*)image:(UIImage*)aImage tintColored:(UIColor*)aTintColor blendingMode:(CGBlendMode)aBlendMode;
-(UIImage*)colored:(UIColor*)aColor;
-(UIImage*)tintColored:(UIColor*)aTintColor;
-(UIImage*)tintColored:(UIColor*)aTintColor blendingMode:(CGBlendMode)aBlendMode;

//
// UIColor指定で単色画像を作る
//

+(UIImage*)imageWithUIColor:(UIColor*)color;


@end
