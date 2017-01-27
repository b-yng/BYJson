//
//  NSObject+RuntimeTools.m
//  QuickBooks Self-Employed
//
//  Created by Young, Braden on 8/31/16.
//  Copyright © 2016 qbse. All rights reserved.
//

#import "NSObject+RuntimeTools.h"
#import <objc/runtime.h>

@implementation NSObject (RuntimeTools)

+ (NSSet<NSString*> *)propertyNames {
    NSString *className = NSStringFromClass(self);
    NSCache<NSString*, NSSet<NSString*>*> *setCache = [self propertyNameSetCache];
    
    // cache property names for duration of program
    NSSet<NSString*> *propertyNameSet = [setCache objectForKey:className];
    if (propertyNameSet == nil) {
        propertyNameSet = [self propertyNamesWithNSObjectProperties:NO];
        [setCache setObject:propertyNameSet forKey:className];
    }
    
    return propertyNameSet;
}

#pragma mark - Helper

+ (NSSet<NSString*> *)propertyNamesWithNSObjectProperties:(BOOL)includeNSObjectProperties {
    Class clazzCursor = self;
    NSMutableSet<NSString*> *propertySet = [[NSMutableSet alloc] init];
    NSSet<NSString*> *NSObjectProperties = nil;
    
    // only grab NSObject property names if we need them. Also don't allow infinite recursive calls
    if (!includeNSObjectProperties) {
        NSObjectProperties = [self NSObjectPropertyNames];
    }
    
    do {
        unsigned int count;
        
        // grab property struct array
        objc_property_t *properties = class_copyPropertyList(clazzCursor, &count);
        
        for (NSUInteger i = 0; i < count; i++) {
            objc_property_t rawProperty = properties[i];
            
            // get name as char array
            const char *propertyNameChars = property_getName(rawProperty);
            
            // convert to NSString
            NSString *propertyNameString = [NSString stringWithUTF8String:propertyNameChars];
            
            if (includeNSObjectProperties || ![NSObjectProperties containsObject:propertyNameString]) {
                [propertySet addObject:propertyNameString];
            }
        }
        
        // free structs
        free(properties);
        
        // iterate class hierarchy
        clazzCursor = [clazzCursor superclass];
    } while ([clazzCursor superclass] != nil);
    
    return propertySet;
}

+ (NSSet<NSString*> *)NSObjectPropertyNames {
    static NSSet<NSString*> *propertyNameSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        propertyNameSet = [NSObject propertyNamesWithNSObjectProperties:YES];
    });
    return propertyNameSet;
}

+ (NSCache<NSString*, NSSet<NSString*>*> *)propertyNameSetCache {
    static NSCache<NSString*, NSSet<NSString*>*> *propertyNameSetCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        propertyNameSetCache = [[NSCache alloc] init];
    });
    return propertyNameSetCache;
}

@end
