//
//  BYJsonMapperFormatters.h
//
//  Created by Young, Braden on 6/26/16.
//  Copyright © 2016 qbse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYJsonMapperFormatters : NSObject

/**
 *  @param number Unix timestamp in milliseconds
 *
 *  @return
 */
+ (NSDate *)NSDateFromNSNumber:(NSNumber *)number;

/**
 *  @param date
 *
 *  @return Unix timestamp in milliseconds
 */
+ (NSNumber *)NSNumberFromNSDate:(NSDate *)date;

/**
 *  @param string full ISO-8601 date string, ISO-8601 without a timezone, or ISO-8601 without time
 *
 *  @return
 */
+ (NSDate *)NSDateFromNSString:(NSString *)string;

/**
 *  @param date
 *
 *  @return ISO-8601 date string using [NSTimeZone defaultTimeZone] as time zone
 */
+ (NSString *)NSStringFromNSDate:(NSDate *)date;

@end
