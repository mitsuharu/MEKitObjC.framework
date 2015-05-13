//
//  NSDate+Enhanced.m
//  MEKitObjC
//
//  Created by Mitsuharu Emoto on 2013/09/06.
//  Copyright (c) 2013年 Mitsuharu Emoto. All rights reserved.
//

#import "NSDate+Enhanced.h"

@implementation NSDate (Enhanced)

-(NSDateComponents*)dateComponents
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unitFlags = (NSCalendarUnitCalendar | NSCalendarUnitYear | NSCalendarUnitMonth
                                | NSCalendarUnitDay | NSCalendarUnitHour
                                | NSCalendarUnitMinute | NSCalendarUnitSecond);
//    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:self];
    return dateComponents;
}


-(BOOL)isToday
{
    BOOL today = NO;
    
    NSDate *localDate = [self dateByAddingTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT]];
    NSDate *localToday = [[NSDate date] dateByAddingTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT]];

    NSInteger daycount = (NSInteger)([localDate timeIntervalSince1970])/86400;
    NSInteger todaycount = (NSInteger)([localToday timeIntervalSince1970])/86400;
    if ( daycount == todaycount ) {
        today = YES;
    }
    
    return today;
}

@end


#pragma mark - NSDate (RFC1123_Private)

@interface NSDate (RFC1123_Private)

+(NSDateFormatter *)rfc1123DateFormatter;
+(NSDateFormatter *)apiDateFormatter;

+(NSDateFormatter *)ISO8601Formatter;
+(NSDateFormatter *)ISO8601TimeFormatter;
+(NSDateFormatter *)ISO8601DateFormatter;

@end

@implementation NSDate (RFC1123_Private)

+(NSDateFormatter *)rfc1123DateFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    //    formatter.locale = [NSLocale systemLocale];
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    formatter.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
    return formatter;
}

+(NSDateFormatter *)apiDateFormatter
{
    // "created_at" = "2013-06-05 17:46:25";
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale currentLocale];
    formatter.timeZone = [NSTimeZone systemTimeZone];
    formatter.dateFormat = @"yyyy'-'MM'-'dd HH':'mm':'ss";
    return formatter;
}

+(NSDateFormatter *)ISO8601Formatter
{
    // "2013-11-15T20:58:42.041559Z";
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setLocale:[NSLocale systemLocale]];
    return formatter;
}

+(NSDateFormatter *)ISO8601TimeFormatter
{
    return [NSDate ISO8601Formatter];
}

+(NSDateFormatter *)ISO8601DateFormatter
{
    // "2013-11-15T20:58:42.041559Z";
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setLocale:[NSLocale systemLocale]];
    return formatter;
}

@end

#pragma mark - NSDate (RFC1123)

@implementation NSDate (RFC1123)

+(NSDate*)dateFromISO8601:(NSString*)string
{
    NSDate *date = nil;
    if( string && [string isKindOfClass:[NSString class]] && string.length > 0){
        NSDateFormatter *formatter = [NSDate ISO8601Formatter];
        date = [formatter dateFromString:string];
        
        if (date == nil) {
            formatter = [NSDate ISO8601DateFormatter];
            date = [formatter dateFromString:string];
        }
        
    }
    return date;
}

-(NSString*)ISO8601String
{
    NSDateFormatter *formatter = [NSDate ISO8601Formatter];
    return [formatter stringFromDate:self];
}

-(NSString*)ISO8601DateString
{
    NSDateFormatter *formatter = [NSDate ISO8601DateFormatter];
    return [formatter stringFromDate:self];
}

-(NSString*)ISO8601TimeString
{
    NSDateFormatter *formatter = [NSDate ISO8601TimeFormatter];
    return [formatter stringFromDate:self];
}

+(NSDate*)dateFromRFC1123:(NSString*)rfc1123String
{
    NSDate *date = nil;
    if( rfc1123String && [rfc1123String isKindOfClass:[NSString class]] &&rfc1123String.length > 0){
        NSDateFormatter *formatter = [NSDate rfc1123DateFormatter];
        date = [formatter dateFromString:rfc1123String];
    }
    return date;
}

-(NSString*)rfc1123String
{
    NSDateFormatter *formatter = [NSDate rfc1123DateFormatter];
    return [formatter stringFromDate:self];
}

+(NSDate*)dateFromAPI:(NSString*)apiString
{
    NSDate *date = nil;
    if( apiString && [apiString isKindOfClass:[NSString class]] &&apiString.length > 0){
        NSDateFormatter *formatter = [NSDate apiDateFormatter];
        date = [formatter dateFromString:apiString];
    }
    return date;
}

-(NSString*)apiString
{
    NSDateFormatter *formatter = [NSDate apiDateFormatter];
    return [formatter stringFromDate:self];
}

@end
