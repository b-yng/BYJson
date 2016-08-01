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

#define JsonFormat(_propertyName, _formatBlock) \
    + (id)formattedValueFor##_propertyName##WithJsonValue:(id)jsonValue { \
        @selector(_propertyName); \
        _formatBlock \
    } \

#endif /* BYJsonMacros_h */
