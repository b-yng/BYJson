//
//  NSObject+BYDebugTools.m
//  BYJson
//
//  Created by Young, Braden on 7/10/16.
//  Copyright © 2016 Braden Young. All rights reserved.
//

#import "NSObject+BYDebugTools.h"
#import <BYJson/BYJson.h>
#import <objc/runtime.h>

@implementation NSObject (BYDebugTools)

- (NSDictionary *)propertyDictionary {
    Class clazzCursor = self.class;
    NSMutableDictionary *propertyDictionary = [[NSMutableDictionary alloc] init];
    
    do {
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList(clazzCursor, &count);
        
        for (NSUInteger i = 0; i < count; i++) {
            objc_property_t rawProperty = properties[i];
            
            // get name
            const char *propertyNameChars = property_getName(rawProperty);
            NSString *propertyName = [NSString stringWithUTF8String:propertyNameChars];
            
            id value = [self valueForKey:propertyName];
            if (value == nil) {
                value = [NSNull null];
            }
            
            if ([value conformsToProtocol:@protocol(BYJsonMappable)]) {
                value = [value propertyDictionary];
            }
            
            propertyDictionary[propertyName] = value;
        }
        
        free(properties);
        clazzCursor = [clazzCursor superclass];
    } while ([clazzCursor superclass] != nil);
    
    return propertyDictionary;
}

@end
