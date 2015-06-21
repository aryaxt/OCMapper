//
//  ObjectInstanceProvider.m
//  OCMapper
//
//  Created by Aryan Gh on 4/20/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//
// https://github.com/aryaxt/OCMapper
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ObjectInstanceProvider.h"

@interface ObjectInstanceProvider()
@property (nonatomic, strong) NSMutableDictionary *propertyNameDictionary;
@end

@implementation ObjectInstanceProvider

#pragma mark - Initialization -

- (id)init
{
	if (self = [super init])
	{
		self.propertyNameDictionary = [NSMutableDictionary dictionary];
	}
	
	return  self;
}

#pragma mark - InstanceProvider Methods -

- (BOOL)canHandleClass:(Class)class
{
	static Class managedObjectClass = nil;
	
	if (!managedObjectClass)
		managedObjectClass = NSClassFromString(@"NSManagedObject");
	
	return ([class isSubclassOfClass:managedObjectClass]) ? NO : YES;
}

- (id)emptyInstanceForClass:(Class)class
{
	return [[class alloc] init];
}

- (id)emptyCollectionInstance
{
	return [NSMutableArray array];
}

- (id)upsertObject:(NSObject *)object error:(NSError **)error;
{
	// Object not stored anywhere and therefore no need to upsert
	// This is specifically made for NSManagedObjects used by ManagedObjectInstanceProvider
	
	return object;
}

- (NSString *)propertyNameForObject:(NSObject *)object byCaseInsensitivePropertyName:(NSString *)caseInsensitivePropertyName
{
	NSString *result = nil;
	Class currentClass = [object class];
	
	NSString *key = [NSString stringWithFormat:@"%@.%@", NSStringFromClass(currentClass), caseInsensitivePropertyName];
	
	if (self.propertyNameDictionary[key])
		return self.propertyNameDictionary[key];
	
	// Support underscore case (EX: map first_name to firstName)
	caseInsensitivePropertyName = [caseInsensitivePropertyName stringByReplacingOccurrencesOfString:@"_" withString:@""];
	
	while (currentClass && currentClass != [NSObject class])
	{
		unsigned int outCount, i;
		objc_property_t *properties = class_copyPropertyList(currentClass, &outCount);
		
		for (i = 0; i < outCount; i++)
		{
			objc_property_t property = properties[i];
			NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
			
			if ([[propertyName lowercaseString] isEqual:[caseInsensitivePropertyName lowercaseString]])
			{
				result = propertyName;
				break;
			}
		}
		
		free(properties);
		
		if (result)
		{
			self.propertyNameDictionary[key] = result;
			return result;
		}
		
		currentClass = class_getSuperclass(currentClass);
	}
	
	return nil;
}

@end
