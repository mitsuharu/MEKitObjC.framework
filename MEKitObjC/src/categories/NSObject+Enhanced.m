//
//  NSObject+Enhanced.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/01/28.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import "NSObject+Enhanced.h"
#import <objc/runtime.h>
#import <objc/objc.h>
#import "MEOUtilities.h"


NSString *const kKeyboardAccessoryRightButtonCompletion = @"kKeyboardAccessoryRightButtonCompletion";
NSString *const kKeyboardAccessoryLeftButtonCompletion = @"kKeyboardAccessoryLeftButtonCompletion";

#pragma mark - NSObject (MyPrivate)

@interface NSObject (MyPrivate)
-(void)callBlock:(MEOBlock)block;
@end

@implementation NSObject (MyPrivate)
-(void)callBlock:(MEOBlock)block
{
    block();
}
@end


#pragma mark - NSObject (Enhanced)

@implementation NSObject (Enhanced)

@end


#pragma mark - NSObject (Blocks)

@implementation NSObject (Blocks)


-(void)dispatchAsync:(MEOBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   block);
}

-(void)dispatchSync:(MEOBlock)block
{
    dispatch_async(dispatch_get_main_queue(),
                   block);
}

-(void)dispatchDelay:(NSTimeInterval)delay block:(MEOBlock)block
{
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW,
                                         delay * (NSTimeInterval)NSEC_PER_SEC);
    dispatch_after(when, dispatch_get_main_queue(), block);
}


- (void)dispatchOnNextRunloop:(MEOBlock)block
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0),
                   dispatch_get_main_queue(),
                   ^(void){
                       block();
                   });
}

-(void)performBlock:(MEOBlock)block afterDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(callBlock:)
               withObject:[block copy]
               afterDelay:delay];
}

-(void)performBlockInBackground:(MEOBlock)block
{
    [self performSelectorInBackground:@selector(callBlock:)
                           withObject:[block copy]];
}

- (void)performBlockOnMainThread:(MEOBlock)block
{
    [self performSelectorOnMainThread:@selector(callBlock:)
                           withObject:[block copy]
                        waitUntilDone:[NSThread isMainThread]];
}

@end

#pragma mark - NSObject (Singleton)

@implementation NSObject (Singleton)

+(id)singleton
{
    static id obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

+(id)share
{
    static id singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
    });
    return singleton;
}

@end

#pragma mark - NSObject (keyboard)

@implementation NSObject (keyboard)

-(void)cacheKeyboard
{
    [NSObject cacheKeyboard];
}

-(void)cacheKeyboardOnNextRunloop:(BOOL)nextRunloop
{
    [NSObject cacheKeyboardOnNextRunloop:nextRunloop];
}


+(void)cacheKeyboard
{
    [NSObject cacheKeyboardOnNextRunloop:false];
}

+(void)cacheKeyboardOnNextRunloop:(BOOL)nextRunloop
{
    void (^block)(void) = ^(void) {
        UITextField *tempTextField = [UITextField new];
        [[[UIApplication sharedApplication] keyWindow] addSubview:tempTextField];
        [tempTextField becomeFirstResponder];
        [tempTextField resignFirstResponder];
        [tempTextField removeFromSuperview];
    };
    
    if (nextRunloop) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0),
                       dispatch_get_main_queue(),
                       ^(void){
                           block();
                       });
    }else{
        block();
    }
}

@end

#pragma mark - NSObject (keyboardAccessory)

@implementation NSObject (keyboardAccessory)

-(void)doKeyboardAccessoryLeftButton:(id)sender
{
    id obj = [self associatedObjectForKey:kKeyboardAccessoryLeftButtonCompletion];
    if (obj) {
        MEOBlock block = (MEOBlock)obj;
        if (block) {
            block();
        }
    }
}

-(void)doKeyboardAccessoryRightButton:(id)sender
{
    id obj = [self associatedObjectForKey:kKeyboardAccessoryRightButtonCompletion];
    if (obj) {
        MEOBlock block = (MEOBlock)obj;
        if (block) {
            block();
        }
    }
}

-(UIView*)keyboardAccessoryWithCloseButton:(MEOBlock)completion
{
    return [self keyboardAccessoryWithLeftButtonTitle:nil
                                 leftButtonCompletion:nil
                                     rightButtonTitle:[MEOUtilities localizedString:@"Close"]
                                rightButtonCompletion:completion];
}

-(UIView*)keyboardAccessoryWithLeftButtonTitle:(NSString*)leftButtonTitle
                          leftButtonCompletion:(MEOBlock)leftButtonCompletion
                              rightButtonTitle:(NSString*)rightButtonTitle
                         rightButtonCompletion:(MEOBlock)rightButtonCompletion
{
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar sizeToFit];
    
    [self setAssociatedObject:leftButtonCompletion
                       forKey:kKeyboardAccessoryLeftButtonCompletion];
    [self setAssociatedObject:rightButtonCompletion
                       forKey:kKeyboardAccessoryRightButtonCompletion];
    
    UIBarButtonItem *leftButton = nil;
    if (leftButtonTitle && leftButtonCompletion) {
        SEL selector = @selector(doKeyboardAccessoryLeftButton:);
        leftButton = [[UIBarButtonItem alloc] initWithTitle:leftButtonTitle
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:selector];
    }
    
    UIBarButtonItem *rightButton = nil;
    if (rightButtonTitle && rightButtonCompletion) {
        SEL selector = @selector(doKeyboardAccessoryRightButton:);
        rightButton = [[UIBarButtonItem alloc] initWithTitle:rightButtonTitle
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:selector];
    }

    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                            action:nil];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:1];
    if (leftButton) {
        [array addObject:leftButton];
    }
    [array addObject:spacer];
    if (rightButton) {
        [array addObject:rightButton];
    }
    
    [toolbar setItems:array];
    
    return toolbar;
}

@end

#pragma mark - NSObject (MethodSwizzling)

@implementation NSObject (MethodSwizzling)

-(void)swizzleMethod:(SEL)method1 withMethod:(SEL)method2
{
    Method from_m = class_getInstanceMethod([self class], method1);
    Method to_m = class_getInstanceMethod([self class], method2);
    if (from_m) {
        method_exchangeImplementations(from_m, to_m);
    }else{
        IMP imp = method_getImplementation(to_m);
        void (^block)() = ^{};
        imp = imp_implementationWithBlock(block);
        const char *type = method_getTypeEncoding(to_m);
        class_addMethod([self class], method1, imp, type);
        [self swizzleMethod:method1 withMethod:method2];
    }
}

@end

#pragma mark - NSObject (AssociatedObject)

@implementation NSObject (AssociatedObject)

-(void)setAssociatedObject:(id)obj forKey:(NSString*)key
{
    objc_setAssociatedObject(self,
                             (__bridge const void *)(key),
                             obj,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id)associatedObjectForKey:(NSString*)key
{
    return objc_getAssociatedObject(self, (__bridge const void *)(key));
}

@end

#pragma mark - NSObject (Notifications)

NSString *const kNotificationKey = @"kNotificationKey";

@implementation NSObject(Notifications)

-(NSString*)descriptionNotifications
{
    return [NSString stringWithFormat:@"%@", [self notificationKeyDict]];
}

-(NSMutableDictionary*)notificationKeyDict
{
    NSMutableDictionary *dict = nil;
    id obj = [self associatedObjectForKey:kNotificationKey];
    if (obj && [obj isKindOfClass:[NSMutableDictionary class]]) {
        dict = (NSMutableDictionary*)obj;
    }else{
        dict = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return dict;
}

-(void)setNotificationKeyDict:(NSMutableDictionary*)dict
{
    [self setAssociatedObject:dict
                       forKey:kNotificationKey];
}


-(BOOL)hasNotificationKey:(NSString*)name;
{
    BOOL result = false;
    NSMutableDictionary *dict = [self notificationKeyDict];
    if (dict && dict.allKeys.count > 0) {
        result = [dict.allKeys containsObject:name];
    }
    return result;
}

-(BOOL)addNotificationKey:(NSString*)name value:(id)value;
{
    BOOL result = false;
    if ([self hasNotificationKey:name] == false) {
        result = true;
        NSMutableDictionary *dict = [self notificationKeyDict];
        [dict setValue:value forKey:name];
        [self setNotificationKeyDict:dict];
    }
    return result;
}

-(BOOL)removeNotificationKey:(NSString*)name;
{
    BOOL result = false;
    if ([self hasNotificationKey:name] == true) {
        result = true;
        NSMutableDictionary *dict = [self notificationKeyDict];
        [dict removeObjectForKey:name];
        [self setNotificationKeyDict:dict];
    }
    return result;
}

-(BOOL)postNotificationName:(NSString*)name
{
    BOOL result = (name && name.length > 0);
    if (result) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:name
                          object:nil];
    }
    return result;
}

-(BOOL)addNotificationName:(NSString*)name
                  selector:(SEL)selector
{
    BOOL result = ([self hasNotificationKey:name] == false);
    if (result) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:selector
                   name:name
                 object:nil];
        [self addNotificationKey:name
                           value:NSStringFromSelector(selector)];
    }
    return result;
}

-(BOOL)addNotificationName:(NSString *)name
                     block:(MEONotificationBlock)block
{
    BOOL result = ([self hasNotificationKey:name] == false);
    if (result) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        id observer = [nc addObserverForName:name
                                      object:nil
                                       queue:nil
                                  usingBlock:^(NSNotification *note)
                       {
                           if (block) {
                               block(note);
                           }
                       }];
        [self addNotificationKey:name value:observer];
    }
    return result;
}


-(BOOL)removeNotificationName:(NSString*)name
{
    BOOL result = ([self hasNotificationKey:name] == true);
    if (result) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        NSMutableDictionary *dict = [self notificationKeyDict];
        id value = [dict objectForKey:name];
        if ([value isKindOfClass:[NSString class]]) {
            [nc removeObserver:self
                          name:name
                        object:nil];
        }else{
            [nc removeObserver:value];
        }
        [self removeNotificationKey:name];
    }
    return result;
}

-(BOOL)removeNotifications
{
    NSMutableDictionary *dict = [self notificationKeyDict];
    if (dict) {
        NSArray *names = [dict.allKeys copy];
        for (NSString *name in names) {
            [self removeNotificationName:name];
        }
        [dict removeAllObjects];
        [self setNotificationKeyDict:nil];
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    
    return true;
}

@end

