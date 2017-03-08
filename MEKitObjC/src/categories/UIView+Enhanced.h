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

/**
 *  自身がaddSubviewされているかの判定
 *
 *  @return もしaddされていればtrue，そうでなければfalse
 */
- (BOOL)isShowing;

-(void)setBackgroundImageFitted:(UIImage*)backgroundImage;
-(void)setBackgroundImage:(UIImage*)backgroundImage;


+(instancetype)instantiateWithNib;
+(instancetype)instantiateWithNib:(NSString*)nibName;

+ (NSArray*)viewsFromInstantiateWithNib;
+ (NSArray*)viewsFromInstantiateWithNib:(NSString*)nibName;

/**
 @brief 反転する
 */
-(void)turnWithTimeInterval:(NSTimeInterval)timeInterval
                turningView:(void (^)(UIView *view))turningView
                preparation:(void (^)(void))preparation
                 completion:(void (^)(BOOL finished))completion;

-(UIImage *)exportImage;

@end

@interface UIView (Layout)

/**
 *  Storybardにおいて，Xibで作成するビューを配置した場合に使用する初期化メソッドを補助する
 *
 * @code
 - (id)awakeAfterUsingCoder:(NSCoder *)aDecoder
 {
 return [self instantiateWithAwakeAfterUsingCoder];
 }
 * @endcode
 * @see http://poormemory.seesaa.net/article/396945550.html
 * @see http://cocoanuts.mobi/2014/03/26/reusable/
 *  @return カスタムビューのインスタンス
 */
- (instancetype)instantiateWithAwakeAfterUsingCoder;

/**
 *  AutoLayoutでの設定したLayouyConstraintsをコピーする
 *
 *  @param aView コピー元のビュー
 */
- (void)copyLayoutConstraintsFrom:(UIView*)aView;

@end
