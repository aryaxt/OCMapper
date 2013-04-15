//
//  ObjectMapper.h
//  iFollow
//
//  Created by Aryan Gh on 4/14/13.
//  Copyright (c) 2013 Aryan Gh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectMappingInfo.h"

@interface ObjectMapper : NSObject

+ (ObjectMapper *)sharedInstance;
- (id)objectFromSource:(NSDictionary *)dictionary toInstanceOfClass:(Class)class;
- (void)mapFromDictionaryKey:(NSString *)dictionaryKey toPropertyKey:(NSString *)propertyKey withObjectType:(Class)objectType forClass:(Class)class;
- (void)mapFromDictionaryKey:(NSString *)dictionaryKey toPropertyKey:(NSString *)propertyKey forClass:(Class)class;

@end
