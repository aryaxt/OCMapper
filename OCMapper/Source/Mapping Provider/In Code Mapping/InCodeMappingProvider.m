//
//  InCodeMappintProvider.m
//  OCMapper
//
//  Created by Aryan Gh on 4/20/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "InCodeMappingProvider.h"

#define KEY_FOR_ARRAY_OF_OBJECT_MAPPING_INFOS @"objectMappingInfos"

@interface InCodeMappingProvider()
@property (nonatomic, strong) NSMutableDictionary *mappingDictionary;
@property (nonatomic, strong) NSMutableDictionary *dateFormatterDictionary;
@end

@implementation InCodeMappingProvider
@synthesize mappingDictionary;
@synthesize dateFormatterDictionary;

#pragma mark - Initialization -

- (id)init
{
	if (self = [super init])
	{
		self.mappingDictionary = [NSMutableDictionary dictionary];
		self.dateFormatterDictionary = [NSMutableDictionary dictionary];
	}
	
	return self;
}

#pragma mark - Public Methods -

- (void)mapFromDictionaryKey:(NSString *)source toPropertyKey:(NSString *)propertyKey withObjectType:(Class)objectType forClass:(Class)class
{
	ObjectMappingInfo *info = [[ObjectMappingInfo alloc] initWithDictionaryKey:source propertyKey:propertyKey andObjectType:objectType];
	NSString *key = [self uniqueKeyForClass:class andKey:source];
	[self.mappingDictionary setObject:info forKey:key];
}

- (void)setDateFormatter:(NSDateFormatter *)dateFormatter forProperty:(NSString *)property andClass:(Class)class
{
	NSString *key = [self uniqueKeyForClass:class andKey:property];
	[self.dateFormatterDictionary setObject:dateFormatter forKey:key];
}

- (void)mapFromDictionaryKey:(NSString *)dictionaryKey toPropertyKey:(NSString *)propertyKey forClass:(Class)class
{
	[self mapFromDictionaryKey:dictionaryKey toPropertyKey:propertyKey withObjectType:nil forClass:class];
}

#pragma mark - public Methods -

- (NSString *)uniqueKeyForClass:(Class)class andKey:(NSString *)key
{
	return [[NSString stringWithFormat:@"%@-%@", NSStringFromClass(class), key] lowercaseString];
}

#pragma mark - MappingProvider Methods -

- (ObjectMappingInfo *)mappingInfoForClass:(Class)class andDictionaryKey:(NSString *)source
{
	NSString *key = [self uniqueKeyForClass:class andKey:source];
	return [self.mappingDictionary objectForKey:key];
}

- (NSDateFormatter *)dateFormatterForClass:(Class)class andProperty:(NSString *)property
{
	NSString *key = [self uniqueKeyForClass:class andKey:property];
	return [self.dateFormatterDictionary objectForKey:key];
}

@end
