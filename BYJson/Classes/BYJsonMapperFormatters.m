//
//  BYJsonMapperFormatters.m
//
//  Created by Young, Braden on 6/26/16.
//  Copyright © 2016 qbse. All rights reserved.
//

#import "BYJsonMapperFormatters.h"
#include <xlocale.h>

static NSDateFormatter *localDateTimeFormatter;
static NSDateFormatter *localDateFormatter;

@implementation BYJsonMapperFormatters

+ (void)load {
    localDateTimeFormatter = [[NSDateFormatter alloc] init];
    [localDateTimeFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    
    localDateFormatter = [[NSDateFormatter alloc] init];
    [localDateFormatter setDateFormat:@"yyyy-MM-dd"];
}


#pragma mark - NSDate

+ (NSDate *)NSDateFromNSNumber:(NSNumber *)number {
    if (number == nil) return nil;
    return [NSDate dateWithTimeIntervalSince1970:number.doubleValue / 1000.0];
}

+ (NSNumber *)NSNumberFromNSDate:(NSDate *)date {
    return @([date timeIntervalSince1970] * 1000.0);
}

+ (NSDate *)NSDateFromNSString:(NSString *)string {
    if (string == nil) return nil;
    
    NSDate *date = [self dateFromIsoString:string];
    if (date != nil)
        return date;
    
    date = [localDateTimeFormatter dateFromString:string];
    if (date != nil)
        return date;
    
    date = [localDateFormatter dateFromString:string];
    
    return date;
}

+ (NSString *)NSStringFromNSDate:(NSDate *)date {
    static NSDateFormatter *isoDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isoDateFormatter = [[NSDateFormatter alloc] init];
        [isoDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        [isoDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    });
    
    return [isoDateFormatter stringFromDate:date];
}

#pragma mark - Helpers

// https://github.com/mattt/TransformerKit/blob/master/TransformerKit/TTTDateTransformers.m
+ (NSDate *)dateFromIsoString:(NSString *)string {
    static unsigned int const ISO_8601_MAX_LENGTH = 29;
    
    const char *source = [string cStringUsingEncoding:NSUTF8StringEncoding];
    char destination[ISO_8601_MAX_LENGTH];
    size_t length = strlen(source);
    
    if (length == 0) {
        return nil;
    }
    
    double milliseconds = 0.0f;
    if (length == 20 && source[length - 1] == 'Z') {
        memcpy(destination, source, length - 1);
        strncpy(destination + length - 1, "+0000\0", 6);
    } else if (length == 24 && source[length - 5] == '.' && source[length - 1] == 'Z') {
        memcpy(destination, source, length - 5);
        strncpy(destination + length - 5, "+0000\0", 6);
        milliseconds = [[string substringWithRange:NSMakeRange(20, 3)] doubleValue] / 1000.0f;
    } else if (length == 25 && source[22] == ':') {
        memcpy(destination, source, 22);
        memcpy(destination + 22, source + 23, 2);
    } else if (length == 29 && source[26] == ':') {
        memcpy(destination, source, 26);
        memcpy(destination + 26, source + 27, 2);
    } else {
        memcpy(destination, source, MIN(length, ISO_8601_MAX_LENGTH - 1));
    }
    
    destination[sizeof(destination) - 1] = 0;
    
    struct tm time = {
        .tm_isdst = -1,
    };
    
    strptime_l(destination, "%FT%T%z", &time, NULL);
    
    return [NSDate dateWithTimeIntervalSince1970:mktime(&time) + milliseconds];
}

@end
