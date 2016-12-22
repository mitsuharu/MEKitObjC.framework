//
//  UIView+Enhanced.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/02/04.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import "UIView+Enhanced.h"
#import <objc/runtime.h>
#define KEY_UIVIEW_ORIGIN_RECT @"KEY_UIVIEW_ORIGIN_RECT"


@implementation UIView (Rectangle)

-(void)addOrigin:(CGPoint)point
{
    CGRect rect = [self rawRect];
    rect.origin.x += point.x;
    rect.origin.y += point.y;
    self.frame = rect;
}

-(void)addSize:(CGSize)size
{
    CGRect rect = [self rawRect];
    rect.size.width += size.width;
    rect.size.height += size.height;
    self.frame = rect;
}

-(void)addRect:(CGRect)rect
{
    CGRect rawRect = [self rawRect];    
    rawRect.origin.x += rect.origin.x;
    rawRect.origin.y += rect.origin.y;
    rawRect.size.width += rect.size.width;
    rawRect.size.height += rect.size.height;
    self.frame = rawRect;
}

-(BOOL)hasRawRect
{
    BOOL has = NO;
    if (objc_getAssociatedObject(self, KEY_UIVIEW_ORIGIN_RECT)) {
        has = YES;
    }
    return has;
}

-(void)saveRawRect
{
    if (objc_getAssociatedObject(self, KEY_UIVIEW_ORIGIN_RECT)) {
        return;
    }
    [self resaveRawRect];
}

-(void)resaveRawRect
{
    NSValue *v = [NSValue valueWithCGRect:self.frame];
    objc_setAssociatedObject(self,
                             KEY_UIVIEW_ORIGIN_RECT,
                             v,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(CGRect)rawRect
{
    CGRect rect = self.frame;
    NSValue *v = objc_getAssociatedObject(self, KEY_UIVIEW_ORIGIN_RECT);
    if (v) {
        rect = [v CGRectValue];
    }else{
        [self saveRawRect];
    }
    return rect;
}

@end


@implementation UIView (Enhanced)

- (BOOL)isShowing
{
    return (self.superview!=nil);
}



-(void)setBackgroundImageFitted:(UIImage*)backgroundImage
{
    UIImage *image = backgroundImage;
    if (backgroundImage) {
        UIGraphicsBeginImageContext(self.frame.size);
        [backgroundImage drawInRect:self.bounds];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    [self setBackgroundImage:image];
}


-(void)setBackgroundImage:(UIImage*)backgroundImage
{
    UIColor *color = [UIColor whiteColor];
    if (backgroundImage) {
        color = [UIColor colorWithPatternImage:backgroundImage];
    }
    self.backgroundColor = color;
}



+(UIView*)instantiateWithNib
{
    NSString *str = NSStringFromClass([self class]);
    NSArray *arr = [str componentsSeparatedByString:@"."];
    
    return [UIView instantiateWithNib:arr.lastObject];
}

+(UIView*)instantiateWithNib:(NSString*)nibName
{
    UINib *nib = [UINib nibWithNibName:nibName
                                bundle:[NSBundle mainBundle]];
    UIView *view = nil;
    if (nib) {
        view = (UIView*)[[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    }
    return view;
}

+ (NSArray*)viewsFromInstantiateWithNib
{
    NSString *str = NSStringFromClass([self class]);
    NSArray *arr = [str componentsSeparatedByString:@"."];
    return [UIView viewsFromInstantiateWithNib:arr.lastObject];
}

+ (NSArray*)viewsFromInstantiateWithNib:(NSString*)nibName
{
    UINib *nib = [UINib nibWithNibName:nibName
                                bundle:[NSBundle mainBundle]];
    NSArray *views = nil;
    if (nib) {
        views = [nib instantiateWithOwner:nil options:nil];
    }
    return views;
}

-(void)turnWithTimeInterval:(NSTimeInterval)timeInterval
                turningView:(void (^)(UIView *view))turningView
                preparation:(void (^)(void))preparation
                 completion:(void (^)(BOOL finished))completion
{
    static BOOL isTurning = false;
    if (isTurning) {
        if (completion) {
            completion(false);
        }
        return;
    }
    isTurning = true;
    
    CGFloat interval = 1.0;
    if (timeInterval >= 0) {
        interval = timeInterval;
    }
    
    // 事前準備
    if (preparation) {
        preparation();
    }
    
    [UIView animateWithDuration:(interval/2.0) animations:^{
        // 90度まで回転
        self.layer.transform = CATransform3DMakeRotation(M_PI * 0.5, 0.0f, 1.0f, 0.0f);
    } completion:^(BOOL finished) {
        
        // 270度までアニメ無しで進める
        self.layer.transform = CATransform3DMakeRotation(M_PI * 1.5, 0.0f, 1.0f, 0.0f);
        
        // 反転処理
        if (turningView) {
            turningView(self);
        }
        
        [UIView animateWithDuration:(interval/2.0) animations:^{
            // 360度まで回転
            self.layer.transform = CATransform3DMakeRotation(M_PI * 2, 0.0f, 1.0f, 0.0f);
        } completion:^(BOOL finished) {
            self.layer.transform = CATransform3DIdentity;
            isTurning = false;
            if (completion) {
                completion(true);
            }
        }];
    }];
}

-(UIImage *)exportImage
{
//    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    return img;
}

@end

@implementation UIView (Layout)

- (void)copyLayoutConstraintsFrom:(UIView*)aView
{
    self.frame = aView.frame;
    self.autoresizingMask = aView.autoresizingMask;
    self.translatesAutoresizingMaskIntoConstraints = aView.translatesAutoresizingMaskIntoConstraints;
    
    for (NSLayoutConstraint *constraint in aView.constraints){
        id firstItem = constraint.firstItem;
        if (firstItem == aView){
            firstItem = self;
        }
        id secondItem = constraint.secondItem;
        if (secondItem == aView){
            secondItem = self;
        }
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:firstItem
                                                         attribute:constraint.firstAttribute
                                                         relatedBy:constraint.relation
                                                            toItem:secondItem
                                                         attribute:constraint.secondAttribute
                                                        multiplier:constraint.multiplier
                                                          constant:constraint.constant]];
    }
}

- (instancetype)instantiateWithAwakeAfterUsingCoder
{
    if (self.subviews.count == 0) {
        Class cls = NSClassFromString([[self class] description]);
        UIView *view = [cls instantiateWithNib];
        [view copyLayoutConstraintsFrom:self];
        return view;
    }else{
        return self;
    }
}

@end

