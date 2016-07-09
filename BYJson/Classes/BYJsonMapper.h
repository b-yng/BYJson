//
//  BYJsonMapper.h
//
//  Created by Young, Braden on 6/26/16.
//  Copyright © 2016 qbse. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BYJsonMappable <NSObject>

@end

@interface BYJsonMapper : NSObject

+ (id)createInstanceOfMappableClass:(Class<BYJsonMappable>)clazz fromJson:(NSDictionary *)json;
+ (void)setDefaultFormattersClass:(Class)formattersClass;

@end

@interface NSObject (BYJsonMapperTools)

+ (instancetype)fromJson:(NSDictionary *)json;

@end