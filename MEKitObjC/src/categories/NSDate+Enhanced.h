//
//  NSDate+Enhanced.h
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/09/06.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Enhanced)

-(NSDateComponents*)dateComponents;
-(BOOL)isToday;
-(NSInteger)age;

@end

@interface NSDate (RFC1123)

+(NSDate*)dateFromRFC1123:(NSString*)rfc1123String;
-(NSString*)rfc1123String;

+(NSDate*)dateFromAPI:(NSString*)apiString;
-(NSString*)apiString;

+(NSDate*)dateFromISO8601:(NSString*)string;
-(NSString*)ISO8601String;

-(NSString*)ISO8601DateString;
-(NSString*)ISO8601TimeString;

@end
