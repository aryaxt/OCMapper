//
//  XMLMappingProvider.m
//  OCMapper
//
//  Created by Aryan Gh on 4/20/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "XMLMappingProvider.h"

@implementation XMLMappingProvider

#pragma mark - Initialization -

- (id)initWithXmlFile:(NSString *)fileName
{
	if (self = [super init])
	{
		NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"xml"];

	}
	
	return self;
}

#pragma mark - MappingProvider Methods -

- (ObjectMappingInfo *)mappingInfoForClass:(Class)class andDictionaryKey:(NSString *)source
{
	return nil;
}

- (NSDateFormatter *)dateFormatterForClass:(Class)class andProperty:(NSString *)property
{
	return nil;
}

@end
