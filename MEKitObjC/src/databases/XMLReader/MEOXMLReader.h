//
//  MEOXMLReader
//
//  Created by Mitsuharu Emoto on 9/18/10.
//  Copyright 2010 Mitsuharu Emoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MEOXMLReader;


typedef void (^MEOXMLReaderBlock)(NSDictionary *dictionary);

@protocol MEOXMLReaderDelegate <NSObject>

@required
-(void)xmlReader:(MEOXMLReader*)xmlReader parsed:(NSDictionary*)dictionary;

@end


@interface MEOXMLReader : NSObject

@property (nonatomic, weak) id<MEOXMLReaderDelegate> delegate;
@property (nonatomic, retain) NSDictionary *userInfo;
@property (nonatomic, retain, readonly) NSError *error;
@property (nonatomic) NSInteger tag;


-(void)parseForXMLString:(NSString *)string completion:(MEOXMLReaderBlock)completion;
-(void)parseXMLData:(NSData *)data completion:(MEOXMLReaderBlock)completion;


-(void)parseForXMLString:(NSString *)string;
-(void)parseXMLData:(NSData *)data;

+(void)parseXMLString:(NSString *)string completion:(MEOXMLReaderBlock)completion;
+(void)parseXMLData:(NSData *)data completion:(MEOXMLReaderBlock)completion;

@end
