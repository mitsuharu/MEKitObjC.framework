//
//  UIImage+Enhanced.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/06/25.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import "UIImage+Enhanced.h"
#import <Accelerate/Accelerate.h>

@implementation UIImage (Enhanced)

-(CGFloat)mbytePng
{
    NSData *imgData = UIImagePNGRepresentation(self);
    CGFloat mbyte = (CGFloat)(imgData.length)/(1024.0*1024.0);
    return mbyte;
}


-(UIImage*)resizedImage:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, 30, 30);
    rect.size = size;

    UIGraphicsBeginImageContext(size);
    [self drawInRect:rect];
    
    NSData *data = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
    UIImage *image = [UIImage imageWithData:data];
    
    UIGraphicsEndImageContext();
    
    return image;
}

-(UIImage*)imageResizedScaleToFill:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(size);
    [self drawInRect:rect];
    NSData *data = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
    UIImage *image = [UIImage imageWithData:data];
    UIGraphicsEndImageContext();
    return image;
}

-(UIImage*)imageResizedAspectFit:(CGSize)size
{
    CGFloat rate = 1.0;
    
    CGSize originSize = self.size;
    if ( originSize.width > originSize.height ) {
        rate = size.width / originSize.width;
    }else{
        rate = size.height / originSize.height;
    }
    
    CGRect shrunkRect = CGRectMake(0.0,
                                   0.0,
                                   originSize.width*rate,
                                   originSize.height*rate);

    CGFloat scale = [[UIScreen mainScreen] scale];
    
    UIGraphicsBeginImageContextWithOptions(shrunkRect.size, NO, scale);

    [self drawInRect:shrunkRect];
    
    NSData *data = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
    UIImage *image = [UIImage imageWithData:data];
    
    UIGraphicsEndImageContext();
    
    
    return image;
}

+ (UIImage *)imageWithString:(NSString *)text
                        size:(CGSize)size
                        font:(UIFont*)font
                   fontColor:(UIColor*)fontColor
                   backColor:(UIColor*)backColor
{
    UIGraphicsBeginImageContextWithOptions(size, false, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 背景色
    UIColor *backgroundColor = backColor;
    if (backColor == nil) {
        backgroundColor = [UIColor clearColor];
    }
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    // フォント
    CGFloat fontSize = [UIFont systemFontSize];
    UIFont *textFont = [UIFont boldSystemFontOfSize:fontSize];
    if (font) {
        textFont = font;
        fontSize = font.pointSize;
    }
    
    // パラグラフ関連の情報の指定
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    style.lineBreakMode = NSLineBreakByClipping;
    
    // 文字修飾
    NSDictionary *attributes = @{
                                 NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: style,
                                 NSForegroundColorAttributeName: fontColor,
                                 NSBackgroundColorAttributeName: [UIColor clearColor]
                                 };
    
    // 文字列を描画する
    [text drawInRect:CGRectMake(0, size.height/2.0-fontSize/2.0, size.width, size.height)
      withAttributes:attributes];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}


+(UIImage*)imageCircleWithRadius:(CGFloat)radius
                           color:(UIColor*)color
{
    return [UIImage imageCircleWithRadius:radius
                                    color:color
                              borderWidth:0
                              borderColor:nil];
}

+(UIImage*)imageCircleWithRadius:(CGFloat)radius
                           color:(UIColor*)color
                     borderWidth:(CGFloat)borderWidth
                     borderColor:(UIColor*)borderColor
{
    CGFloat tempRadius = radius - borderWidth;
    CGSize contextSize = CGSizeMake(radius*2.0, radius*2.0);
    CGRect drawnRect = CGRectMake(borderWidth/2, borderWidth/2, tempRadius*2.0, tempRadius*2.0);
    
    UIGraphicsBeginImageContextWithOptions(contextSize, false, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *circleColor = [UIColor blackColor];
    if (color) {
        circleColor = color;
    }
    CGContextSetFillColorWithColor(context, circleColor.CGColor);
    
    CGContextSetLineWidth(context, borderWidth);
    if (borderWidth > 0) {
        if (borderColor) {
            CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
        }else{
            CGContextSetStrokeColorWithColor(context, circleColor.CGColor);
        }
    }
    
    CGContextAddEllipseInRect(context, drawnRect);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}



-(UIImage*)rasterizedImage:(CGFloat)rasterizationScale
{
    UIImage *image1 = self;
    CGFloat width = image1.size.width;
    CGFloat height = image1.size.height;
    CGFloat scale = rasterizationScale;
    CGFloat sWidth = width*scale;
    CGFloat sHeight = height*scale;
    
    UIGraphicsBeginImageContext(CGSizeMake(sWidth, sHeight));
    [image1 drawInRect:CGRectMake(0, 0, sWidth, sHeight)];
    UIImage *image2 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [image2 drawInRect:CGRectMake(0, 0, width, height)];
    UIImage *image3 = UIGraphicsGetImageFromCurrentImageContext();
    
    return image3;
}


-(UIImage*)blurredImage
{
    return [self blurredImageWithBlurLevel:0.5];
}

-(UIImage*)blurredImageWithBlurLevel:(CGFloat)blurLevel
{
    UIImage *image = self;
    CGFloat blur = blurLevel;
    
    if ((blur < 0.0f) || (blur > 1.0f)) {
        blur = 0.5f;
    }
    
    int boxSize = (int)(blur * 100);
    boxSize -= (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL,
                                       0, 0, boxSize, boxSize, NULL,
                                       kvImageEdgeExtend);
    
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(image.CGImage));
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}


@end

@implementation UIImage (Colorway)

#pragma mark - 1つの画像から色違い画像を作る

+(UIImage*)image:(UIImage*)aImage colored:(UIColor*)aColor
{
    UIImage *coloredImage = [aImage colored:aColor];
    return coloredImage;
}

+(UIImage*)image:(UIImage*)aImage tintColored:(UIColor*)aTintColor
{
    UIImage *coloredImage = [aImage tintColored:aTintColor];
    return coloredImage;
}
+(UIImage*)image:(UIImage*)aImage tintColored:(UIColor*)aTintColor blendingMode:(CGBlendMode)aBlendMode
{
    UIImage *coloredImage = [aImage tintColored:aTintColor blendingMode:aBlendMode];
    return coloredImage;
}

-(UIImage*)colored:(UIColor*)aColor
{
    CGSize size = CGSizeMake(self.size.width, self.size.height);
    CGRect rect = CGRectMake(0.0, 0.0, self.size.width, self.size.height);
    
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, [self CGImage]);
    CGContextSetFillColorWithColor(context, [aColor CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

-(UIImage*)tintColored:(UIColor*)aTintColor
{
    // kCGBlendModeHardLight
    return [self tintColored:aTintColor blendingMode:kCGBlendModeSoftLight];
}

-(UIImage*)tintColored:(UIColor*)aTintColor blendingMode:(CGBlendMode)aBlendMode
{
    // 参照
    // http://robots.thoughtbot.com/post/46668544473/designing-for-ios-blending-modes
    //
    
    CGSize size = CGSizeMake(self.size.width, self.size.height);
    CGRect rect = CGRectMake(0.0, 0.0, self.size.width, self.size.height);
    
    UIGraphicsBeginImageContext(size);
    [aTintColor setFill];
    UIRectFill(rect);
    [self drawInRect:rect blendMode:aBlendMode alpha:1.0f];
    
    if (aBlendMode != kCGBlendModeDestinationIn){
        [self drawInRect:rect
               blendMode:kCGBlendModeDestinationIn
                   alpha:1.0];
    }
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}


#pragma mark - UIColor指定で単色画像を作る

+(UIImage*)imageWithUIColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(contextRef, [color CGColor]);
    CGContextFillRect(contextRef, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage*)circleImageWithRadius:(CGFloat)radius color:(UIColor*)color
{
    CGRect rect = CGRectMake(0, 0, ceilf(radius*2), ceilf(radius*2));
    
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(context, r, g, b, 1);
    CGContextFillEllipseInRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end

