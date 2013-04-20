//
//  ObjectMapper.h
//  OCMapper
//
//  Created by Aryan Gh on 4/14/13.
//  Copyright (c) 2013 Aryan Gh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "ObjectMappingInfo.h"
#import "InstanceProvider.h"
#import "ObjectInstanceProvider.h"

@interface ObjectMapper : NSObject

@property (nonatomic, strong) NSDateFormatter *defaultDateFormatter;
@property (nonatomic, strong) id <InstanceProvider> instanceProvider;

+ (ObjectMapper *)sharedInstance;
- (id)objectFromSource:(id)source toInstanceOfClass:(Class)class;
- (NSDictionary *)dictionaryFromObject:(NSObject *)object;
- (void)mapFromDictionaryKey:(NSString *)dictionaryKey toPropertyKey:(NSString *)propertyKey withObjectType:(Class)objectType forClass:(Class)class;
- (void)mapFromDictionaryKey:(NSString *)dictionaryKey toPropertyKey:(NSString *)propertyKey forClass:(Class)class;
- (void)setDateFormatter:(NSDateFormatter *)dateFormatter forProperty:(NSString *)property andClass:(Class)class;

@end
