//
//  ObjectMapperInfo.m
//  OCMapper
//
//  Created by Aryan Gh on 4/14/13.
//  Copyright (c) 2013 Aryan Gh. All rights reserved.
//

#import "ObjectMappingInfo.h"

@implementation ObjectMappingInfo
@synthesize dictionaryKey;
@synthesize propertyKey;
@synthesize objectType;

#pragma mark - Initialization -

- (id)initWithDictionaryKey:(NSString *)aDictionaryKey propertyKey:(NSString *)aPropertyKey andObjectType:(Class)anObjectType
{
	if (self = [super init])
	{
		self.dictionaryKey = aDictionaryKey;
		self.propertyKey = aPropertyKey;
		self.objectType = anObjectType;
	}
	
	return self;
}

+ (id)objectMappingInfoWithDictionaryKey:(NSString *)dictionaryKey propertyKey:(NSString *)propertyKey andObjectType:(Class)objectType
{
	return [[ObjectMappingInfo alloc] initWithDictionaryKey:dictionaryKey propertyKey:propertyKey andObjectType:objectType];
}

+ (id)objectMappingInfoWithDictionaryKey:(NSString *)dictionaryKey propertyKey:(NSString *)propertyKey
{
	return [ObjectMappingInfo objectMappingInfoWithDictionaryKey:dictionaryKey propertyKey:propertyKey andObjectType:nil];
}

@end
