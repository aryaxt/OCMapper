//
//  ObjectMapper.m
//  OCMapper
//
//  Created by Aryan Gh on 4/14/13.
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

#import "ObjectMapper.h"

#ifdef DEBUG
#define ILog(format, ...) [self.loggingProvider log:[NSString stringWithFormat:(format), ##__VA_ARGS__] withLevel:LogLevelInfo]
#define WLog(format, ...) [self.loggingProvider log:[NSString stringWithFormat:(format), ##__VA_ARGS__] withLevel:LogLevelWarning]
#define ELog(format, ...) [self.loggingProvider log:[NSString stringWithFormat:(format), ##__VA_ARGS__] withLevel:LogLevelError]
#else
#define ILog(format, ...) /* */
#define WLog(format, ...) /* */
#define ELog(format, ...) /* */
#endif

@interface ObjectMapper()
@property (nonatomic, strong) NSMutableArray *commonDateFormaters;
@property (nonatomic, strong) NSMutableArray *classNamesInMainBundle;
@property (nonatomic, strong) NSMutableDictionary *mappedClassNames;
@end

@implementation ObjectMapper
@synthesize defaultDateFormatter;
@synthesize commonDateFormaters;
@synthesize instanceProvider;
@synthesize mappingProvider;
@synthesize loggingProvider;

#pragma mark - initialization -

+ (ObjectMapper *)sharedInstance
{
	static ObjectMapper *singleton;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		singleton = [[ObjectMapper alloc] init];
	});
	
	return singleton;
}

- (id)init
{
	if (self = [super init])
	{
		[self populateClassNamesFromMainBundle];
	}
	
	return self;
}

#pragma mark - Public Methods -

- (id)objectFromSource:(id)source toInstanceOfClass:(Class)class
{
	if (!mappingProvider)
		@throw ([NSException exceptionWithName:@"MissingMappingProvider" reason:@"Mapping provider is not set" userInfo:nil]);
	
	if (!instanceProvider)
		@throw ([NSException exceptionWithName:@"MissingInstanceProvider" reason:@"Instance provider is not set" userInfo:nil]);
	
	if ([source isKindOfClass:[NSDictionary class]])
	{
		ILog(@"____________________ Mapping Dictionary to instance [%@] ____________________", NSStringFromClass(class));
		return [self processDictionary:source forClass:class];
	}
	else if ([source isKindOfClass:[NSArray class]])
	{
		ILog(@"____________________   Mapping Array to instance [%@] ____________________", NSStringFromClass(class));
		return [self processArray:source forClass:class];
	}
	else
	{
		ILog(@"____________________   Mapping field [%@] ____________________", NSStringFromClass(class));
		return source;
	}
}

- (id)dictionaryFromObject:(NSObject *)object
{
	if ([object isKindOfClass:[NSArray class]])
	{
		return [self processDictionaryFromArray:(NSArray *)object];
	}
	else
	{
		return [self processDictionaryFromObject:object];
	}
}

#pragma mark - Private Methods -

- (void)populateClassNamesFromMainBundle
{
	self.classNamesInMainBundle = [NSMutableArray array];
	
	int numClasses;
	Class *classes = NULL;
	
	classes = NULL;
	numClasses = objc_getClassList(NULL, 0);
	
	if (numClasses > 0)
	{
		classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
		numClasses = objc_getClassList(classes, numClasses);
		
		for (int i = 0; i < numClasses; i++)
		{
			@autoreleasepool
			{
				Class class = classes[i];
				
				if ([NSBundle bundleForClass:class] == [NSBundle mainBundle])
					[self.classNamesInMainBundle addObject:NSStringFromClass(class)];
			}
		}
	}
		
	free(classes);
}

- (NSArray *)processDictionaryFromArray:(NSArray *)array
{
	NSMutableArray *result = [NSMutableArray array];
	
	for (id valueInArray in array)
	{
		[result addObject:[self dictionaryFromObject:valueInArray]];
	}
	
	return result;
}

- (NSDictionary *)processDictionaryFromObject:(NSObject *)object
{
	NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([object class], &outCount);
	
    for (i = 0; i < outCount; i++)
	{
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
		Class class = NSClassFromString([self typeForProperty:propertyName andClass:[object class]]);
        id propertyValue = [object valueForKey:(NSString *)propertyName];
		
		// If class is in the main bundle it's an application specific class
		if ([NSBundle mainBundle] == [NSBundle bundleForClass:[propertyValue class]])
		{
			if (propertyValue) [props setObject:[self dictionaryFromObject:propertyValue] forKey:propertyName];
		}
		// It's not in the main bundle so it's a Cocoa Class
		else
		{
			if (class == [NSDate class])
			{
				propertyValue = [propertyValue description];
			}
			else if ([propertyValue isKindOfClass:[NSArray class]] || [propertyValue isKindOfClass:[NSSet class]])
			{
				propertyValue = [self processDictionaryFromArray:propertyValue];
			}
			
			
			if (propertyValue) [props setObject:propertyValue forKey:propertyName];
		}
    }
	
    free(properties);
    return props;
}

// Here we normalize dictionary made for flat-to-complex-object mapping
// For instance in a mapping from "city" to "address.city" we break down "address" and "city"
- (NSDictionary *)normalizedDictionaryFromDictionary:(NSDictionary *)source forClass:(Class)class
{
	NSMutableDictionary *newDictionary = [NSMutableDictionary dictionary];
	
	for (NSString *key in source)
	{
		@autoreleasepool
		{
			ObjectMappingInfo *mapingIngo = [self.mappingProvider mappingInfoForClass:class andDictionaryKey:key];
			NSRange rangeOfSeparator = [mapingIngo.propertyKey rangeOfString:@"."];
			
			if (rangeOfSeparator.length)
			{
				NSString *className = [mapingIngo.propertyKey substringToIndex:rangeOfSeparator.location];
				NSString *property = [mapingIngo.propertyKey substringFromIndex:rangeOfSeparator.location+1];
				
				NSMutableDictionary *nestedDictionary = [newDictionary objectForKey:className];
				
				if (!nestedDictionary)
					nestedDictionary = [NSMutableDictionary dictionary];
				
				[nestedDictionary setObject:[source objectForKey:key] forKey:property];
				[newDictionary setObject:nestedDictionary forKey:className];
			}
			else
			{
				[newDictionary setObject:[source objectForKey:key] forKey:key];
			}
		}
	}
	
	return newDictionary;
}

- (id)processDictionary:(NSDictionary *)source forClass:(Class)class
{
	NSDictionary *normalizedSource = [self normalizedDictionaryFromDictionary:source forClass:class];
	
	id object = [self.instanceProvider emptyInstanceFromClass:class];
	
	for (NSString *key in normalizedSource)
	{
		@autoreleasepool
		{
			ObjectMappingInfo *mappingInfo = [self.mappingProvider mappingInfoForClass:class andDictionaryKey:key];
			id value = [normalizedSource objectForKey:(NSString *)key];
			NSString *propertyName;
			Class objectType;
			id nestedObject;
			
			if (mappingInfo)
			{
				propertyName = [self.instanceProvider propertyNameForObject:object byCaseInsensitivePropertyName:mappingInfo.propertyKey];
				objectType = mappingInfo.objectType;
			}
			else
			{
				propertyName = [self.instanceProvider propertyNameForObject:object byCaseInsensitivePropertyName:key];
				
				if (propertyName && ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]))
				{
					objectType = [self classFromString:key];
				}
			}
			
			if (class && object && propertyName && [object respondsToSelector:NSSelectorFromString(propertyName)])
			{
				ILog(@"Mapping key(%@) to property(%@) from data(%@)", key, propertyName, [value class]);
				
				if ([value isKindOfClass:[NSDictionary class]])
				{
					nestedObject = [self processDictionary:value forClass:objectType];
				}
				else if ([value isKindOfClass:[NSArray class]])
				{
					nestedObject = [self processArray:value forClass:objectType];
				}
				else
				{
					if ([[self typeForProperty:propertyName andClass:class] isEqual:@"NSDate"])
					{
						if ([value isKindOfClass:[NSDate class]])
						{
							nestedObject = value;
						}
						else if ([value isKindOfClass:[NSString class]])
						{
							nestedObject = [self dateFromString:value forProperty:propertyName andClass:class];
						}
					}
					else
					{
						nestedObject = value;
					}
				}
				
				if ([object respondsToSelector:NSSelectorFromString(propertyName)])
				{
					if ([nestedObject isKindOfClass:[NSNull class]])
						nestedObject = nil;
					
					[object setValue:nestedObject forKey:propertyName];
				}
			}
			else
			{
				WLog(@"Unable to map from  key(%@) to property(%@) for class (%@)", key, propertyName, NSStringFromClass(class));
			}
		}
	}
	
	return object;
}

- (id)processArray:(NSArray *)value forClass:(Class)class
{
	id collection = [self.instanceProvider emptyInstanceOfCollectionObject];
	
	for (id objectInArray in value)
	{
		id nestedObject = [self objectFromSource:objectInArray toInstanceOfClass:class];
		
		if (nestedObject)
			[collection addObject:nestedObject];
	}

	return collection;
}

- (Class)classFromString:(NSString *)className
{
	Class result = [self.mappedClassNames objectForKey:className];
	
	if (result)
		return result;
	
	if (NSClassFromString(className))
		return NSClassFromString(className);
	
	if (NSClassFromString([className capitalizedString]))
		return NSClassFromString([className capitalizedString]);
	
	NSString *classNameLowerCase = [className lowercaseString];
	
	for (NSString *className in self.classNamesInMainBundle)
	{
		@autoreleasepool
		{
			NSString *thisClassNameLowerCase = [className lowercaseString];
			
			if ([thisClassNameLowerCase isEqual:classNameLowerCase] ||
				[[NSString stringWithFormat:@"%@s", thisClassNameLowerCase] isEqual:classNameLowerCase] ||
				[[NSString stringWithFormat:@"%@es", thisClassNameLowerCase] isEqual:classNameLowerCase])
			{
				result = NSClassFromString(className);
				[self.mappedClassNames setObject:result forKey:className];
				break;
			}
		}
	}
	
	return result;
}

- (NSDate *)dateFromString:(NSString *)string forProperty:(NSString *)property andClass:(Class)class
{
	NSDate *date;
	NSDateFormatter *customDateFormatter = [self.mappingProvider dateFormatterForClass:class andProperty:property];
	
	if (customDateFormatter)
	{
		date = [customDateFormatter dateFromString:string];
		ILog(@"attempting to convert date '%@' on property '%@' for class [%@] using 'customDateFormatter' (%@)", date, property, NSStringFromClass(class), customDateFormatter.dateFormat);
	}
	else if (self.defaultDateFormatter)
	{
		date = [self.defaultDateFormatter dateFromString:string];
		ILog(@"attempting to convert '%@' on property '%@' for class [%@] using 'defaultDateFormatter' (%@)", date, property, NSStringFromClass(class), self.defaultDateFormatter.dateFormat);
	}
	
	if (!date)
	{
		for (NSDateFormatter *dateFormatter in self.commonDateFormaters)
		{
			date = [dateFormatter dateFromString:string];
			ILog(@"attempting to convert date(%@) on property(%@) for class(%@) using 'commonDateFormaters' (%@)", date, property, NSStringFromClass(class), dateFormatter.dateFormat);
			
			if (date)
			{
				ILog(@"Converted date(%@) on property(%@) for class(%@) using 'commonDateFormaters' (%@)", date, property, NSStringFromClass(class), dateFormatter.dateFormat);
				break;
			}
		}
	}
	
	if (!date)
		ELog(@"Unable to convert date(%@) on property(%@) for class(%@)", date, property, NSStringFromClass(class));
	
	return date;
}

- (NSMutableArray *)commonDateFormaters
{
	if (!commonDateFormaters)
	{
		commonDateFormaters = [NSMutableArray array];
		
		NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
		[formatter1 setDateFormat:@"yyyy-MM-dd"];
		[commonDateFormaters addObject:formatter1];
		
		NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
		[formatter2 setDateFormat:@"MM/dd/yyyy"];
		[commonDateFormaters addObject:formatter2];
		
		NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
		[formatter3 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ"];
		[commonDateFormaters addObject:formatter3];
		
		NSDateFormatter *formatter4 = [[NSDateFormatter alloc] init];
		[formatter4 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		[commonDateFormaters addObject:formatter4];
		
		NSDateFormatter *formatter5 = [[NSDateFormatter alloc] init];
		[formatter5 setDateFormat:@"MM/dd/yyyy HH:mm:ss aaa"];
		[commonDateFormaters addObject:formatter5];
		
		NSDateFormatter *formatter6 = [[NSDateFormatter alloc] init];
		[formatter6 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
		[commonDateFormaters addObject:formatter6];
	}
	
	return commonDateFormaters;
}

- (NSString *)typeForProperty:(NSString *)property andClass:(Class)class
{	
	const char *type = property_getAttributes(class_getProperty(class, [property UTF8String]));
	NSString *typeString = [NSString stringWithUTF8String:type];
	NSArray *attributes = [typeString componentsSeparatedByString:@","];
	NSString *typeAttribute = [attributes objectAtIndex:0];
	return [[[typeAttribute substringFromIndex:1]
			 stringByReplacingOccurrencesOfString:@"@" withString:@""]
			stringByReplacingOccurrencesOfString:@"\"" withString:@""];
}

@end
