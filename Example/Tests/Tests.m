//
//  BYJsonTests.m
//  BYJsonTests
//
//  Created by Braden Young on 07/07/2016.
//  Copyright (c) 2016 Braden Young. All rights reserved.
//

@import XCTest;
#import <BYJson/BYJson.h>
#import "BYTrip.h"
#import "NSObject+BYDebugTools.h"

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBYTrip {
    NSDictionary *json = [self jsonFromFileNamed:@"Trip"];
    
    BYTrip *trip = [BYTrip fromJson:json];
    NSLog(@"trip=%@", trip.propertyDictionary);
    XCTAssertNotNil(trip);
}

- (NSDictionary *)jsonFromFileNamed:(NSString *)fileName {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:fileName ofType:@"json"];
    XCTAssertNotNil(filePath);
    
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    XCTAssertNotNil(jsonData);
    
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    XCTAssertNil(error, @"Error serializing json data; error=%@", error);
    XCTAssertNotNil(json);
    return json;
}

@end

