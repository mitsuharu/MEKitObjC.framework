//
//  UIResponder+Enhanced.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2015/03/27.
//  Copyright (c) 2015年 Mitsuharu Emoto. All rights reserved.
//

#import "UIResponder+Enhanced.h"
#import <objc/runtime.h>
#import <objc/objc.h>

NSString *const kMEOStatusBarTappedNotification = @"kMEOStatusBarTappedNotification";
NSString *const keyExchangedTouchesEndedWithEvent = @"keyExchangedTouchesEndedWithEvent";

@interface UIResponder (Enhanced_private)

-(BOOL)exchangedTouchesEndedWithEvent;
-(void)setExchangedTouchesEndedWithEvent:(BOOL)exchanged;
-(void)swizzleMethod:(SEL)method1
          withMethod:(SEL)method2;
-(void)exchangedTouchesEnded:(NSSet *)touches
                   withEvent:(UIEvent *)event;

@end

@implementation UIResponder (Enhanced_private)

-(void)swizzleMethod:(SEL)method1 withMethod:(SEL)method2
{
    Method from_m = class_getInstanceMethod([self class], method1);
    Method to_m = class_getInstanceMethod([self class], method2);
    if (from_m) {
        method_exchangeImplementations(from_m, to_m);
    }else{
        IMP imp = method_getImplementation(to_m);
        void (^block)(void) = ^{};
        imp = imp_implementationWithBlock(block);
        const char *type = method_getTypeEncoding(to_m);
        class_addMethod([self class], method1, imp, type);
        [self swizzleMethod:method1 withMethod:method2];
    }
}

-(BOOL)exchangedTouchesEndedWithEvent
{
    id obj = objc_getAssociatedObject(self,
                                      (__bridge const void *)(keyExchangedTouchesEndedWithEvent));
    BOOL exchanged = false;
    if (obj && [obj isKindOfClass:[NSNumber class]]) {
        NSNumber *num = (NSNumber*)obj;
        exchanged = [num boolValue];
    }
    return exchanged;
}

-(void)setExchangedTouchesEndedWithEvent:(BOOL)exchanged
{
    objc_setAssociatedObject(self,
                             (__bridge const void *)(keyExchangedTouchesEndedWithEvent),
                             [NSNumber numberWithBool:exchanged],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)exchangedTouchesEnded:(NSSet *)touches
                   withEvent:(UIEvent *)event
{
    [self exchangedTouchesEnded:touches withEvent:event];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGPoint location = [[[event allTouches] anyObject] locationInView:window];
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    if (CGRectContainsPoint(statusBarFrame, location)){
        [[NSNotificationCenter defaultCenter] postNotificationName:kMEOStatusBarTappedNotification
                                                            object:nil];
    }
}

@end


@implementation UIResponder (Enhanced)

-(void)addStatusBarTappedNotification
{
    if ([self exchangedTouchesEndedWithEvent] == false) {
        [self setExchangedTouchesEndedWithEvent:true];
        [self swizzleMethod:@selector(touchesEnded:withEvent:)
                 withMethod:@selector(exchangedTouchesEnded:withEvent:)];
        
        if (self && [self respondsToSelector:@selector(statusBarTapped:)]) {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(statusBarTapped:)
                       name:kMEOStatusBarTappedNotification
                     object:nil];
        }
    }
}

-(void)removeStatusBarTappedNotification
{
    if ([self exchangedTouchesEndedWithEvent] == true) {
        [self setExchangedTouchesEndedWithEvent:false];
        [self swizzleMethod:@selector(exchangedTouchesEnded:withEvent:)
                 withMethod:@selector(touchesEnded:withEvent:)];
        
        if (self && [self respondsToSelector:@selector(statusBarTapped:)]) {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc removeObserver:self
                          name:kMEOStatusBarTappedNotification
                        object:nil];
        }
    }
}

@end
