//
//  UILabel+Enhanced.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/06/18.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import "UILabel+Enhanced.h"
#import "NSObject+Enhanced.h"
#import <CoreText/CoreText.h>

@implementation UILabel (Enhanced)

@end




NSString *const kKeyVertically = @"kKeyVertically";
NSString *const kKeyVerticalPadding = @"kKeyVerticalPadding";

@implementation UILabel (Vertical)


-(UIEdgeInsets)verticalPadding
{
    NSValue *value = [self associatedObjectForKey:kKeyVerticalPadding];
    UIEdgeInsets result = UIEdgeInsetsMake(5, 2, 0, 0);
    if (value && [value isKindOfClass:[NSValue class]]) {
        result = [value UIEdgeInsetsValue];
    }
    return result;
}

-(void)setVerticalPadding:(UIEdgeInsets)padding
{
    [self setAssociatedObject:[NSValue valueWithUIEdgeInsets:padding]
                       forKey:kKeyVerticalPadding];
}

-(CGRect)renderingRect
{
    CGRect rect = self.bounds;
    
    UIEdgeInsets padding = [self verticalPadding];
    rect.origin.x -= padding.left;
    rect.origin.y -= padding.top;
    rect.size.width -= (padding.left + padding.right);
    rect.size.height -= (padding.top + padding.bottom);
    return rect;
}

-(BOOL)verticalWriting
{
    NSNumber *number = [self associatedObjectForKey:kKeyVertically];
    BOOL result = false;
    if (number && [number isKindOfClass:[NSNumber class]]) {
        result = [number boolValue];
    }
    return result;
}

-(void)setVerticalWriting:(BOOL)verticalWriting
{
    BOOL preVerticalWriting = [self verticalWriting];
    
    [self setAssociatedObject:[NSNumber numberWithBool:verticalWriting]
                       forKey:kKeyVertically];
    
    
    if (verticalWriting == true && preVerticalWriting == false) {
        [self swizzleMethod:@selector(drawRect:)
                 withMethod:@selector(drawRectVertically:)];
        [self setNeedsDisplay];
    }else if (verticalWriting == false && preVerticalWriting == true){
        [self swizzleMethod:@selector(drawRectVertically:)
                 withMethod:@selector(drawRect:)];
        [self setNeedsDisplay];
    }
}


-(NSAttributedString*)verticalAttributedString
{
    NSString *string = self.text;
    if (self.attributedText
        && self.attributedText.string
        && self.attributedText.string.length > 0)
    {
        string = self.attributedText.string;
    }
    
    UIColor* textColor = self.textColor;
    NSInteger fontSize = self.font.pointSize;
    CTFontRef font = CTFontCreateWithName(CFSTR("HiraKakuProN-W3"), fontSize, NULL);
    
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.minimumLineHeight = 10;
    paragraphStyle.lineSpacing = 0;
    
    NSDictionary *attributes = @{NSFontAttributeName:(__bridge_transfer id)font,
                                 NSForegroundColorAttributeName:textColor,
                                 NSParagraphStyleAttributeName:paragraphStyle,
                                 (__bridge id)kCTVerticalFormsAttributeName:@YES};
    
    NSAttributedString *attributedString = nil;
    if (string) {
        attributedString = [[NSAttributedString alloc] initWithString:string
                                                           attributes:attributes];
    }
    
    return attributedString;
}

-(CGRect)verticalWritingRect
{
    CGRect rect = CGRectMake(0, 0, 0, 0);
    NSAttributedString *attributedString = [self verticalAttributedString];
    if (attributedString) {
        CGRect rect2 = [attributedString boundingRectWithSize:CGSizeMake(self.frame.size.height, CGFLOAT_MAX)
                                                      options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                      context:nil];
        rect = CGRectMake(0, 0, rect2.size.height, rect2.size.width);
    }
    return rect;
}

- (void)drawRectVertically:(CGRect)rect
{
    // 他のクラスへの影響を防ぐため縦書きフラグで判定する
    BOOL verticalWriting = [self verticalWriting];
    if (verticalWriting == false) {
        [self drawRectVertically:rect];
        return;
    }
    
    // 縦書き用の属性付き文字列
    NSAttributedString *attributedString = [self verticalAttributedString];
    
    // 描画領域の設定
    CGRect renderingRect = [self renderingRect];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(attributedString));
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:renderingRect];
    NSDictionary* frameAttributes = @{@"CTFrameProgression": @(kCTFrameProgressionRightToLeft)};
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
                                                CFRangeMake(0, 0),
                                                path.CGPath,
                                                (__bridge CFDictionaryRef)frameAttributes);
    
    //  描画用コンテキスト取り出し
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, renderingRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CTFrameDraw(frame, context);
    
    // 掃除
    CFRelease(frame);
    CFRelease(framesetter);
}


@end