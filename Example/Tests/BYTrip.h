//
//  BYTrip.h
//  BYJson
//
//  Created by Young, Braden on 7/8/16.
//  Copyright © 2016 Braden Young. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BYAddress.h"
#import <BYJson/BYJson.h>

@interface BYTrip : NSObject

@property (nonatomic, readonly) NSNumber *tripId;
@property (nonatomic) NSNumber *distance;
@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;
@property (nonatomic, readonly) NSDate *dateUpdated;
//@property (nonatomic) BYTripReviewState reviewState;
@property (nonatomic) NSString *businessPurpose;
@property (nonatomic) NSString *notes;
@property (nonatomic) BYAddress *startAddress;
@property (nonatomic) BYAddress *endAddress;
//@property (nonatomic) BYLocation *startLocation;
//@property (nonatomic) BYLocation *endLocation;
@property (nonatomic) id userCreated;
//@property (nonatomic) BYTripRoute *route;
//@property (nonatomic) NSManagedObjectID *managedObjectId;
@property (nonatomic) NSString *logFileName;
@property (nonatomic) NSNumber *deductionAmount;
@property (nonatomic) NSNumber *vehicleId;
@property (nonatomic) NSString *vehicleDescription;
//@property (nonatomic) BYVehicleType vehicleType;

@end
