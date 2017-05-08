//
//  NSDateFormatter+Enhanced.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2017/04/14.
//  Copyright © 2017年 Mitsuharu Emoto. All rights reserved.
//

#import "NSDateFormatter+Enhanced.h"

@implementation NSDateFormatter (Enhanced)

+ (NSDateFormatter*)meo_dateFormatter
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    df.locale = [NSLocale systemLocale];
    df.timeZone = [NSTimeZone systemTimeZone];
    
    return df;
}


@end
