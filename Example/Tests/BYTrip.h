//
//  BYTrip.h
//  BYJson
//
//  Created by Young, Braden on 7/8/16.
//  Copyright © 2016 Braden Young. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BYJson/BYJson.h>

@interface BYTrip : NSObject

JsonKey(id)
@property (nonatomic, readonly) NSNumber *tripId;

@property (nonatomic) NSNumber *distance;

JsonKey(startDateTime)
@property (nonatomic) NSDate *startDate;

JsonKey(endDateTime)
@property (nonatomic) NSDate *endDate;

@property (nonatomic, readonly) NSDate *dateUpdated;
//@property (nonatomic) QBSETripReviewState reviewState;
@property (nonatomic) NSString *businessPurpose;
@property (nonatomic) NSString *notes;
//@property (nonatomic) QBSEAddress *startAddress;
//@property (nonatomic) QBSEAddress *endAddress;
//@property (nonatomic) QBSELocation *startLocation;
//@property (nonatomic) QBSELocation *endLocation;
@property (nonatomic) id userCreated;
//@property (nonatomic) QBSETripRoute *route;
//@property (nonatomic) NSManagedObjectID *managedObjectId;
@property (nonatomic) NSString *logFileName;
@property (nonatomic) NSNumber *deductionAmount;
@property (nonatomic) NSNumber *vehicleId;
@property (nonatomic) NSString *vehicleDescription;
//@property (nonatomic) QBSEVehicleType vehicleType;

@end
