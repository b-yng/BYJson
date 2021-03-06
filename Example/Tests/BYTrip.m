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

JsonKey(tripId, id)
JsonKey(distance, tripMiles)
JsonKey(startDate, startDateTime)
JsonFormat(startDate, { return [BYJsonMapperFormatters NSDateFromNSString:jsonValue]; })
JsonKey(endDate, endDateTime)
JsonFormat(endDate, { return [BYJsonMapperFormatters NSDateFromNSString:jsonValue]; })

@end
