//
//  UIView+Enhanced.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/02/04.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (Rectangle)

-(BOOL)hasRawRect;
-(void)saveRawRect;
-(void)resaveRawRect;
-(CGRect)rawRect;
-(void)addOrigin:(CGPoint)point;
-(void)addSize:(CGSize)size;
-(void)addRect:(CGRect)rect;

@end




@interface UIView (Enhanced)

-(void)setBackgroundImageFitted:(UIImage*)backgroundImage;
-(void)setBackgroundImage:(UIImage*)backgroundImage;


+(UIView*)instantiateWithNib;
+(UIView*)instantiateWithNib:(NSString*)nibName;


/**
 @brief 反転する
 */
-(void)turnWithTimeInterval:(NSTimeInterval)timeInterval
                turningView:(void (^)(UIView *view))turningView
                preparation:(void (^)(void))preparation
                 completion:(void (^)(BOOL finished))completion;

-(UIImage *)exportImage;

@end
