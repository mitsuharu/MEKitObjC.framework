//
//  NSObject+Enhanced.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/01/28.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef void (^MEOBlock)(void);
typedef void (^MEOBlockWithCompletion)(BOOL completion);
typedef void (^MEOBlockWithError)(NSError *error);

#pragma mark - NSObject (Enhanced)

@interface NSObject (Enhanced)
@end

#pragma mark - NSObject (Blocks)

@interface NSObject (Blocks)

-(void)dispatchAsync:(MEOBlock)block;
-(void)dispatchSync:(MEOBlock)block;
-(void)dispatchDelay:(NSTimeInterval)delay block:(MEOBlock)block;
- (void)dispatchOnNextRunloop:(MEOBlock)block;

-(void)performBlockInBackground:(MEOBlock)block;
-(void)performBlockOnMainThread:(MEOBlock)block;
-(void)performBlock:(MEOBlock)block afterDelay:(NSTimeInterval)delay;

/**
 非同期で複数の処理を行い，全て完了したら同期処理を行う
 
 @param asyncs 前処理（非同期）
 @param completion 完了処理（同期）
 
 @code
 [self dispatchAsyncs:@[^{
 // 事前処理0
 },^{
 // 事前処理1
 }]
 completion:^{
 // 完了処理
 }];
 @endcode
 
 */
- (void)dispatchAsyncs:(NSArray<MEOBlock>*)asyncs
            completion:(MEOBlock)completion;

@end

#pragma mark - NSObject (Singleton)

@interface NSObject (Singleton)
+(instancetype)singleton;
+(instancetype)share;
@end

#pragma mark - NSObject (keyboardAccessory)

@interface NSObject (keyboardAccessory)

-(UIView*)keyboardAccessoryWithCloseButton:(MEOBlock)completion;

-(UIView*)keyboardAccessoryWithLeftButtonTitle:(NSString*)leftButtonTitle
                          leftButtonCompletion:(MEOBlock)leftButtonCompletion
                              rightButtonTitle:(NSString*)rightButtonTitle
                         rightButtonCompletion:(MEOBlock)rightButtonCompletion;
@end

#pragma mark - NSObject (keyboardAccessory)

@interface NSObject (keyboard)

-(void)cacheKeyboard;
-(void)cacheKeyboardOnNextRunloop:(BOOL)nextRunloop;

+(void)cacheKeyboard;
+(void)cacheKeyboardOnNextRunloop:(BOOL)nextRunloop;

@end

#pragma mark - NSObject (MethodSwizzling)

@interface NSObject (MethodSwizzling)

/**
 @brief 既存メソッドの入れ替え
 
 @code
 -(void)hogehoge
 {
 [self swizzleMethod:@selector(viewWillAppear:) withMethod:@selector(viewWillAppear2:)];
 }
 
 -(void)viewWillAppear2:(BOOL)animated
 {
 [self viewWillAppear2:animated];
 // any code
 }
 @endcode
 
 */
-(void)swizzleMethod:(SEL)method1 withMethod:(SEL)method2;

@end

#pragma mark - NSObject (AssociatedObject)

@interface NSObject (AssociatedObject)

-(void)setAssociatedObject:(id)obj forKey:(NSString*)key;
-(id)associatedObjectForKey:(NSString*)key;

@end

#pragma mark - NSObject (Notifications)

typedef void (^MEONotificationBlock)(NSNotification *notification);

@interface NSObject(Notifications)

-(NSString*)descriptionNotifications;

-(BOOL)postNotificationName:(NSString*)name;

-(BOOL)addNotificationName:(NSString*)name
                  selector:(SEL)selector;

-(BOOL)addNotificationName:(NSString *)name
                     block:(MEONotificationBlock)block;

-(BOOL)removeNotificationName:(NSString*)name;

-(BOOL)removeNotifications;

@end

#pragma mark - NSObject (MemoryAddress)

/**
 インスタンスのメモリアドレスを取得する
 */
@interface NSObject (MemoryAddress)
- (NSString*)meo_memoryAddress;
@end

