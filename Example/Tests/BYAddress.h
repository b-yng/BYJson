//
//  BYAddress.h
//  BYJson
//
//  Created by Young, Braden on 7/11/16.
//  Copyright © 2016 Braden Young. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYAddress : NSObject

@property (nonatomic) NSString *street;
@property (nonatomic) NSString *city;
@property (nonatomic) NSString *state;
@property (nonatomic) NSString *postalCode;
@property (nonatomic) NSString *countryCode;

@end
