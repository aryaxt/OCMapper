//
//  ObjectMapperInfo.m
//  iFollow
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

@end
