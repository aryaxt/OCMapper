//
//  ObjectInstanceProvider.m
//  OCMapper
//
//  Created by Aryan Gh on 4/20/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "ObjectInstanceProvider.h"

@implementation ObjectInstanceProvider

#pragma mark - InstanceProvider Methods -

- (id)emptyInstanceFromClass:(Class)class
{
	return [[class alloc] init];
}

- (id)emptyInstanceOfCollectionObject
{
	return [NSMutableArray array];
}

- (NSString *)propertyNameForObject:(NSObject *)object byCaseInsensitivePropertyName:(NSString *)caseInsensitivePropertyName
{
	unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([object class], &outCount);
	
    for (i = 0; i < outCount; i++)
	{
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
		
		if ([[propertyName lowercaseString] isEqual:[caseInsensitivePropertyName lowercaseString]])
		{
			return propertyName;
		}
	}
	
	return nil;
}

@end
