//
//  BYJsonMapper.m
//
//  Created by Young, Braden on 6/26/16.
//  Copyright © 2016 qbse. All rights reserved.
//

#import "BYJsonMapper.h"
#import <objc/runtime.h>
#import "BYJsonMapperFormatters.h"


@interface BYProperty : NSObject
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *typeName;
@property (nonatomic) Class typeClass;
@property (nonatomic) BOOL isPrimitive;
@end

@interface BYMethod : NSObject
@property (nonatomic) NSString *name;
@property (nonatomic) SEL selector;
@end


static Class defaultFormattersClass;


@implementation BYJsonMapper

+ (void)load {
    defaultFormattersClass = [BYJsonMapperFormatters class];
}

+ (id)createInstanceOfMappableClass:(Class)clazz fromJson:(NSDictionary *)json {
    NSAssert([clazz conformsToProtocol:@protocol(BYJsonMappable)], @"Class must conform to BYJsonMappable protocol");
    
    NSObject<BYJsonMappable> *anInstance = [[clazz alloc] init];
    NSArray<BYProperty*> *properties = [self propertiesOfClass:clazz];
    
    for (id propertyOrAnnotation in properties) {
        BYProperty *property = propertyOrAnnotation;
        NSString *jsonKey = nil;
        
        // check for custom key
        BYMethod *jsonKeyMethod = [self jsonKeyMethodForPropertyName:property.name];
        if ([clazz respondsToSelector:jsonKeyMethod.selector]) {
            jsonKey = [self invokeMethod:jsonKeyMethod withClass:clazz object:nil];
        }
        
        // default to property name
        if (jsonKey == nil) {
            jsonKey = property.name;
        }
        
        // grab json value from dictionary and set if it's not null
        id jsonValue = [self valueFromJson:json forKey:jsonKey];
        if (jsonValue == nil) continue;
        
        // primitives are already handled
        if (property.isPrimitive) {
            [anInstance setValue:jsonValue forKey:property.name];
            continue;
        }
        
        // get formatted value if we have formatters available
        id formattedValue = nil;
        
        // find method to format json value
        BYMethod *formatterMethod = [self formattedValueMethodForJsonKey:jsonKey];
        if ([clazz respondsToSelector:formatterMethod.selector]) {
            // check for formatter method at class scope
            formattedValue = [self invokeMethod:formatterMethod withClass:clazz object:jsonValue];
        }
        else {
            // check for recognized cases
            formattedValue = [self recognizedFormattedValueWithClass:property.typeClass parentClass:clazz jsonValue:jsonValue jsonKey:jsonKey];
        }
        
        // check for default formatter methods
        if (formattedValue == nil) {
            formattedValue = [self formattedValueUsingFormatterClassWithDesiredClass:property.typeClass jsonValue:jsonValue];
        }
        
        // use formatted value, if we have one
        if (formattedValue != nil) {
            jsonValue = formattedValue;
        }
        
        NSAssert(jsonValue == nil || [jsonValue isKindOfClass:property.typeClass], @"json value type doesn't match property type");
        
        [anInstance setValue:jsonValue forKey:property.name];
    }
    
    return anInstance;
}

+ (void)setDefaultFormattersClass:(Class)formattersClass {
    defaultFormattersClass = formattersClass;
}

#pragma mark - Helpers


+ (NSArray<BYProperty*> *)propertiesOfClass:(Class)clazz {
    Class clazzCursor = clazz;
    NSMutableArray *propertyArray = [[NSMutableArray alloc] init];
    
    do {
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList(clazzCursor, &count);
        
        for (NSUInteger i = 0; i < count; i++) {
            objc_property_t rawProperty = properties[i];

            // get name
            const char *propertyNameChars = property_getName(rawProperty);
            NSString *propertyNameString = [NSString stringWithUTF8String:propertyNameChars];
            
            // get type
            const char *propertyTypeAttributes = property_getAttributes(rawProperty);
            NSString *propertyAttributesString = [NSString stringWithUTF8String:propertyTypeAttributes];
            NSArray<NSString*> *propertyAttributePartArray = [propertyAttributesString componentsSeparatedByString:@","];
            NSString *typeAttr = propertyAttributePartArray[0];
            NSString *propertyType = [typeAttr substringFromIndex:1];
            const char *rawPropertyType = [propertyType UTF8String];
            
            NSString *typeString = nil;
            BOOL isPrimitive = NO;
            
            if ([typeAttr hasPrefix:@"T@"] && [typeAttr length] > 1) {
                typeString = [typeAttr substringWithRange:NSMakeRange(3, typeAttr.length - 4)];  // @"NSNumber" -> NSNumber
            }
            else {
                isPrimitive = YES;
                
                if (strcmp(rawPropertyType, @encode(BOOL)) == 0) {
                    typeString = @"BOOL";
                }
                else if (strcmp(rawPropertyType, @encode(int)) == 0) {
                    typeString = @"int";
                }
                else if (strcmp(rawPropertyType, @encode(float)) == 0) {
                    typeString = @"float";
                }
                else if (strcmp(rawPropertyType, @encode(double)) == 0) {
                    typeString = @"double";
                }
            }
            
            if (typeString != nil) {
                BYProperty *property = [[BYProperty alloc] init];
                property.name = propertyNameString;
                property.typeName = typeString;
                property.isPrimitive = isPrimitive;
                property.typeClass = !isPrimitive ? NSClassFromString(typeString) : nil;
                [propertyArray addObject:property];
            }
        }
        
        free(properties);
        clazzCursor = [clazzCursor superclass];
    } while ([clazzCursor superclass] != nil);
    
    return propertyArray;
}

+ (id)valueFromJson:(NSDictionary *)json forKey:(NSString *)key {
    NSArray<NSString*> *parts = [key componentsSeparatedByString:@"."];
    if (parts.count <= 1) {
        return json[key];
    }
    else {
        // support nested keys
        id jsonPart = json;
        for (NSString *keyPart in parts) {
            NSAssert([jsonPart isKindOfClass:[NSDictionary class]], @"Failed to grab nested value with key=%@", key);
            jsonPart = jsonPart[keyPart];
        }
        return jsonPart;
    }
}

+ (BYMethod *)jsonKeyMethodForPropertyName:(NSString *)propertyName {
    BYMethod *method = [[BYMethod alloc] init];
    method.name = [NSString stringWithFormat:@"jsonKeyFor%@", propertyName];
    method.selector = NSSelectorFromString(method.name);
    return method;
}

+ (BYMethod *)formattedValueMethodForJsonKey:(NSString *)jsonKey {
    BYMethod *method = [[BYMethod alloc] init];
    method.name = [NSString stringWithFormat:@"formattedValueFor%@WithJsonValue:", jsonKey];
    method.selector = NSSelectorFromString(method.name);
    return method;
}

+ (BYMethod *)genericClassOfMethodWithJsonKey:(NSString *)jsonKey {
    BYMethod *method = [[BYMethod alloc] init];
    method.name = [NSString stringWithFormat:@"genericClassOf%@", jsonKey];
    method.selector = NSSelectorFromString(method.name);
    return method;
}

+ (id)formattedValueUsingFormatterClassWithDesiredClass:(Class)desiredClass jsonValue:(id)jsonValue {
    Class fromClass = [self baseClassFromClass:[jsonValue class]];
    if (desiredClass == fromClass) {
        return nil; // we already have the type we're looking for
    }
    
    NSString *toType = NSStringFromClass(desiredClass);
    NSString *fromType = NSStringFromClass(fromClass);
    NSString *methodName = [NSString stringWithFormat:@"%@From%@", toType, fromType];
    
    NSDictionary<NSString*, BYMethod*> *formatterMethods = [self methodsOfClass:defaultFormattersClass];
    BYMethod *formatterMethod = formatterMethods[methodName];
    if (formatterMethod != nil) {
        id formattedValue = [self invokeMethod:formatterMethod withClass:defaultFormattersClass object:jsonValue];
        return formattedValue;
    }
    else {
        return nil;
    }
}

+ (id)recognizedFormattedValueWithClass:(Class)desiredClass parentClass:(Class)parentClass jsonValue:(id)jsonValue jsonKey:(NSString *)jsonKey {
    
    // BYJsonMappable
    if ([desiredClass conformsToProtocol:@protocol(BYJsonMappable)]) {
        NSAssert([jsonValue isKindOfClass:[NSDictionary class]], @"Property of BYJsonMappable type expects a json value of type NSDictionary");
        
        return [self createInstanceOfMappableClass:desiredClass fromJson:jsonValue];
    }
    
    // NSArray
    if ([desiredClass isSubclassOfClass:[NSArray class]]) {    // TODO: NSSet support
        NSAssert([jsonValue isKindOfClass:[NSArray class]], @"Property of NSArray type expects a json value of type NSArray");
        
        NSArray *jsonArray = jsonValue;
        NSMutableArray *mappedJsonArray = [[NSMutableArray alloc] initWithCapacity:jsonArray.count];
        
        // smartly map array
        for (id jsonArrayItem in jsonArray) {
            id mappedJsonArrayItem = nil;
            id genericClass = nil;
            
            BYMethod *method = [self genericClassOfMethodWithJsonKey:jsonKey];
            if ([parentClass respondsToSelector:method.selector]) {
                genericClass = [self invokeMethod:method withClass:parentClass object:nil];
            }
            
            // if we don't have any generic type info at runtime, we're s.o.l
            if (genericClass == nil) {
                [mappedJsonArray addObject:jsonArrayItem];
                continue;
            }
            
            // try to map dictionary to BYJsonMappable object
            if ([jsonArrayItem isKindOfClass:[NSDictionary class]]) {
                
                // check if generic is a Class that implements BYJsonMappable
                if (class_isMetaClass(object_getClass(genericClass)) &&
                    [genericClass conformsToProtocol:@protocol(BYJsonMappable)]) {
                    
                    mappedJsonArrayItem = [self createInstanceOfMappableClass:genericClass fromJson:jsonArrayItem];
                }
            }
            
            // try to map item using default formatter methods
            if (mappedJsonArrayItem == nil) {
                mappedJsonArrayItem = [self formattedValueUsingFormatterClassWithDesiredClass:genericClass jsonValue:jsonValue];
            }
            
            if (mappedJsonArrayItem != nil) {
                [mappedJsonArray addObject:mappedJsonArrayItem];
            } else {
                [mappedJsonArray addObject:jsonArrayItem];
            }
        }
        
        return mappedJsonArray;
    }
    
    return nil;
}

+ (NSDictionary<NSString*, BYMethod*> *)methodsOfClass:(Class)clazz {
    static NSDictionary *cachedDictionary = nil;
    static Class cachedClass = nil;
    
    if (clazz == cachedClass) {
        return cachedDictionary;
    }
    
    unsigned int count;
    Method *methods = class_copyMethodList(self, &count);
    NSMutableDictionary<NSString*,BYMethod*> *methodDictionary = [[NSMutableDictionary alloc] initWithCapacity:count];
    
    for (NSUInteger i = 0; i < count; i++) {
        Method rawMethod = methods[i];
        SEL selector = method_getName(rawMethod);
        NSString *name = NSStringFromSelector(selector);
        
        BYMethod *method = [[BYMethod alloc] init];
        method.selector = selector;
        method.name = name;
        if (name != nil) {
            methodDictionary[name] = method;
        }
    }
    
    free(methods);
    
    cachedDictionary = methodDictionary;
    cachedClass = clazz;
    
    return methodDictionary;
}

// NSJSONSerialization likes to give back sub class of foundation classes
+ (Class)baseClassFromClass:(Class)class {
    if ([class isSubclassOfClass:[NSString class]])
        return [NSString class];
    
    if ([class isSubclassOfClass:[NSNumber class]])
        return [NSNumber class];
    
    if ([class isSubclassOfClass:[NSArray class]])
        return [NSArray class];
    
    if ([class isSubclassOfClass:[NSDictionary class]])
        return [NSDictionary class];
    
    return class;
}

+ (id)invokeMethod:(BYMethod *)method withClass:(Class)clazz object:(id)object {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (object == nil) {
        return [clazz performSelector:method.selector];
    } else {
        return [clazz performSelector:method.selector withObject:object];
    }
#pragma clang diagnostic pop
}

@end

@implementation NSObject (BYJsonMapperTools)

+ (instancetype)fromJson:(NSDictionary *)json {
    return [BYJsonMapper createInstanceOfMappableClass:[self class] fromJson:json];
}

@end

@implementation BYAnnotation
@end

@implementation BYProperty
@end

@implementation BYMethod
@end

