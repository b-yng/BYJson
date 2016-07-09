//
//  BYTrip.m
//  BYJson
//
//  Created by Young, Braden on 7/8/16.
//  Copyright © 2016 Braden Young. All rights reserved.
//

#import "BYTrip.h"

@interface BYTrip () <BYJsonMappable>

@end

@implementation BYTrip

+ (NSString *)jsonKeyFortripId {
    return @"id";
}

@end
