//
//  IndicatorView.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 10/04/21.
//  Copyright 2010 Mitsuharu Emoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class MEOIndicatorView;

@protocol MEOIndicatorViewDelegate <NSObject>
@optional
-(void)indicatorViewShown:(MEOIndicatorView*)indicatorView;
-(void)indicatorViewRemoved:(MEOIndicatorView*)indicatorView;
-(void)indicatorViewDidCancel:(MEOIndicatorView*)indicatorView;
@end



@interface MEOIndicatorView : UIView

@property (nonatomic, retain) id<MEOIndicatorViewDelegate> delegate;
@property (nonatomic) BOOL enableTapEvents;
@property (nonatomic) BOOL isVisible;

-(void)setText:(NSString *)text;
-(void)setCancelTitle:(NSString *)cancelTitle;

-(void)show;
-(void)show:(BOOL)enableTapEvents;

-(void)remove;

+(void)show;
+(void)show:(NSString*)title;
+(void)show:(NSString*)title tapEvent:(BOOL)enable;
+(void)setText:(NSString*)text;
+(void)remove;


@end
