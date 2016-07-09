//
//  BYJsonMapper.h
//
//  Created by Young, Braden on 6/26/16.
//  Copyright © 2016 qbse. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JsonKey(_BYKEY) @property (nonatomic, readonly) BOOL  _by_keyannotation_##_BYKEY;

typedef id (^BYValueTransformerBlock)(id fromValue);

@protocol BYJsonMappable <NSObject>

@end

@interface BYJsonMapper : NSObject

+ (id)createInstanceOfMappableClass:(Class<BYJsonMappable>)clazz fromJson:(NSDictionary *)json;
+ (void)setDefaultFormattersClass:(Class)formattersClass;

@end

@interface NSObject (BYJsonMapperTools)

+ (instancetype)fromJson:(NSDictionary *)json;

@end