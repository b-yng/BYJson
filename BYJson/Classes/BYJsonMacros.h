//
//  BYJsonMacros.h
//  Pods
//
//  Created by Young, Braden on 7/9/16.
//
//

#ifndef BYJsonMacros_h
#define BYJsonMacros_h

#define JsonKey(_propertyName, _jsonKey) \
    + (NSString *)jsonKeyFor##_propertyName { \
        @selector(_propertyName); \
        return @#_jsonKey; \
    } \

#endif /* BYJsonMacros_h */
