//
//  BYAddress.m
//  BYJson
//
//  Created by Young, Braden on 7/11/16.
//  Copyright © 2016 Braden Young. All rights reserved.
//

#import "BYAddress.h"
#import <BYJson/BYJson.h>

@interface BYAddress () <BYJsonMappable>

@end

@implementation BYAddress

JsonKey(street, addressLine1)
JsonKey(countryCode, country)

@end
