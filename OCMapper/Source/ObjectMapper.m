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
#import <objc/runtime.h>
#import "ObjectMappingInfo.h"
#import "InstanceProvider.h"
#import "MappingProvider.h"
#import "LoggingProvider.h"
#import "ObjectInstanceProvider.h"

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
@property (nonatomic, strong) NSMutableDictionary *mappedClassNames;
@property (nonatomic, strong) NSMutableDictionary *mappedPropertyNames;
@property (nonatomic, strong) NSMutableArray *instanceProviders;
@end

@implementation ObjectMapper

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
		self.instanceProviders = [NSMutableArray array];
		ObjectInstanceProvider *objectInstanceProvider = [[ObjectInstanceProvider alloc] init];
		[self addInstanceProvider:objectInstanceProvider];
		
		self.mappedClassNames = [NSMutableDictionary dictionary];
		self.mappedPropertyNames = [NSMutableDictionary dictionary];
	}
	
	return self;
}

#pragma mark - Public Methods -

- (id)objectFromSource:(id)source toInstanceOfClass:(Class)class
{
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

- (void)addInstanceProvider:(id <InstanceProvider>)instanceProvider
{
	[self.instanceProviders addObject:instanceProvider];
}

#pragma mark - Private Methods -

- (NSArray *)processDictionaryFromArray:(NSArray *)array
{
	NSMutableArray *result = [NSMutableArray array];
	
	for (id valueInArray in array)
	{
		[result addObject:[self dictionaryFromObject:valueInArray]];
	}
	
	return result;
}

- (id)processDictionaryFromObject:(NSObject *)object
{
	// For example when we are mapping an array of string, we shouldn't try to map the string objects inside the array
	if ([NSBundle mainBundle] != [NSBundle bundleForClass:object.class] && [object class] != [NSArray class])
	{
		return object;
	}
	
	NSMutableDictionary *props = [NSMutableDictionary dictionary];
	
	Class currentClass = [object class];
	
	while (currentClass && currentClass != [NSObject class])
	{
		unsigned int outCount, i;
		objc_property_t *properties = class_copyPropertyList(currentClass, &outCount);
		NSArray *excludedKeys = [self.mappingProvider excludedKeysForClass:currentClass];
		
		for (i = 0; i < outCount; i++)
		{
			objc_property_t property = properties[i];
			NSString *originalPropertyName = [NSString stringWithUTF8String:property_getName(property)];
			
			if (excludedKeys && [excludedKeys containsObject:originalPropertyName]) {
				continue;
			}
			
			Class class = NSClassFromString([self typeForProperty:originalPropertyName andClass:[object class]]);
			id propertyValue = [object valueForKey:(NSString *)originalPropertyName];
			
			ObjectMappingInfo *mapingInfo = [self.mappingProvider mappingInfoForClass:[object class] andPropertyKey:originalPropertyName];
			NSString *propertyName = (mapingInfo) ? mapingInfo.dictionaryKey : originalPropertyName;
			
			if (mapingInfo.transformer) {
				propertyValue = mapingInfo.transformer(propertyValue, object);
				[props setObject:propertyValue forKey:propertyName];
			}
			// If class is in the main bundle it's an application specific class
			else if ([NSBundle mainBundle] == [NSBundle bundleForClass:[propertyValue class]])
			{
				if (propertyValue) [props setObject:[self dictionaryFromObject:propertyValue] forKey:propertyName];
			}
			// It's not in the main bundle so it's a Cocoa Class
			else
			{
				if (class == [NSDate class])
				{
					NSDateFormatter *dateFormatter = [self.mappingProvider dateFormatterForClass:[object class] andDictionaryKey:originalPropertyName];
					
					if (!dateFormatter)
						dateFormatter = self.defaultDateFormatter;
					
					if (dateFormatter)
					{
						propertyValue = [self.defaultDateFormatter stringFromDate:propertyValue];
					}
					else
					{
						propertyValue = [propertyValue description];
					}
				}
				else if ([propertyValue isKindOfClass:[NSArray class]] || [propertyValue isKindOfClass:[NSSet class]])
				{
					propertyValue = [self processDictionaryFromArray:propertyValue];
				}
				
				if (propertyValue) [props setObject:propertyValue forKey:propertyName];
			}
		}
		
		free(properties);
		currentClass = class_getSuperclass(currentClass);
	}
	
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
	NSDictionary *normalizedSource = (self.normalizeDictionary) ? [self normalizedDictionaryFromDictionary:source forClass:class] : source;
	
	id <InstanceProvider> instanceProvider = [self instanceProviderForClass:class];
	id object = [instanceProvider emptyInstanceForClass:class];
	
	for (NSString *key in normalizedSource)
	{
		@autoreleasepool
		{
			ObjectMappingInfo *mappingInfo = [self.mappingProvider mappingInfoForClass:class andDictionaryKey:key];
			id value = [normalizedSource objectForKey:(NSString *)key];
			NSString *propertyName;
			MappingTransformer mappingTransformer;
			Class objectType;
			id nestedObject;
			
			if (mappingInfo)
			{
				propertyName = [instanceProvider propertyNameForObject:object byCaseInsensitivePropertyName:mappingInfo.propertyKey];
				objectType = mappingInfo.objectType;
				mappingTransformer = mappingInfo.transformer;
			}
			else
			{
				propertyName = [instanceProvider propertyNameForObject:object byCaseInsensitivePropertyName:key];
				
				if (propertyName && ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]))
				{
					if ([value isKindOfClass:[NSDictionary class]])
					{
						objectType = [self classFromString:[self typeForProperty:propertyName andClass:class]];
					}
					
					if (!objectType)
					{
						objectType = [self classFromString:key];
					}
				}
			}
			
			if (class && object && propertyName && [object respondsToSelector:NSSelectorFromString(propertyName)])
			{
				ILog(@"Mapping key(%@) to property(%@) from data(%@)", key, propertyName, [value class]);
				
				if (mappingTransformer)
				{
					nestedObject = mappingTransformer(value, source);
				}
				else if ([value isKindOfClass:[NSDictionary class]])
				{
					nestedObject = [self processDictionary:value forClass:objectType];
				}
				else if ([value isKindOfClass:[NSArray class]])
				{
					nestedObject = [self processArray:value forClass:objectType];
				}
				else
				{
					NSString *propertyTypeString = [self typeForProperty:propertyName andClass:class];
					
					// Convert NSString to NSDate if needed
					if ([propertyTypeString isEqualToString:@"NSDate"])
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
					// Convert NSString to NSNumber if needed
					else if ([propertyTypeString isEqualToString:@"NSNumber"] && [value isKindOfClass:[NSString class]])
					{
						nestedObject = [NSNumber numberWithDouble:[value doubleValue]];
					}
					// Convert NSNumber to NSString if needed
					else if ([propertyTypeString isEqualToString:@"NSString"] && [value isKindOfClass:[NSNumber class]])
					{
						nestedObject = [value stringValue];
					}
					else
					{
						nestedObject = value;
					}
				}
				
				if ([nestedObject isKindOfClass:[NSNull class]])
					nestedObject = nil;
				
				[object setValue:nestedObject forKey:propertyName];
			}
			else
			{
				WLog(@"Unable to map from  key(%@) to property(%@) for class (%@)", key, propertyName, NSStringFromClass(class));
			}
		}
	}
	
	NSError *error;
	object = [instanceProvider upsertObject:object error:&error];
	
	if (error)
		ELog(@"Attempt to update existing instance failed with error '%@' for class (%@) and object %@",
			 error.localizedDescription,
			 NSStringFromClass(class),
			 object);
	
	return object;
}

- (id <InstanceProvider>)instanceProviderForClass:(Class)class
{
	for (id<InstanceProvider> instanceProvider in self.instanceProviders)
	{
		if ([instanceProvider canHandleClass:class])
			return instanceProvider;
	}
	
	ELog(@"Could not find an instance provider that can handle class '%@'", NSStringFromClass(class));
	
	return nil;
}

- (id)processArray:(NSArray *)value forClass:(Class)class
{
	id <InstanceProvider> instanceProvider = [self instanceProviderForClass:class];
	id collection = [instanceProvider emptyCollectionInstance];
	
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
	Class result;
	
	if ([self.mappedClassNames objectForKey:className])
	{
		result = NSClassFromString([self.mappedClassNames objectForKey:className]);
		
		if (result)
			return result;
	}
	
	__weak typeof(self) weakSelf = self;
	
	Class (^testClassName)(NSString *) = ^(NSString *classNameToTest) {
		Class clazz = NSClassFromString(classNameToTest);
		
		if (clazz)
		{
			[weakSelf.mappedClassNames setObject:classNameToTest forKey:className];
		}
		
		return clazz;
	};
	
	// Handle underscore conversion (ex: game_states to an array of GameState objects)
	// Try using regex instead?
	if ([className rangeOfString:@"_"].length) {
		NSMutableString *newString = [NSMutableString string];

		[[className componentsSeparatedByString:@"_"] enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
			[newString appendString:obj.capitalizedString];
		}];
		
		className = newString;
	}
	
	NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
	
	if (className.length) {
		className = [className stringByReplacingCharactersInRange:NSMakeRange(0,1)
													   withString:[[className substringToIndex:1] capitalizedString]];
	}
	
	NSString *predictedClassName = className;
	if (testClassName(predictedClassName)) { return testClassName(predictedClassName); }
	
	predictedClassName = [NSString stringWithFormat:@"%@.%@", appName ,className];
	if (testClassName(predictedClassName)) { return testClassName(predictedClassName); }
	
	// EX: if keyword is "posts" try to find a class named "Post"
	if ([className hasSuffix:@"s"])
	{
		NSString *classNameWithoutS = [className substringToIndex:className.length-1];
		
		predictedClassName = [NSString stringWithFormat:@"%@", classNameWithoutS];
		if (testClassName(predictedClassName)) { return testClassName(predictedClassName); }
		
		predictedClassName = [NSString stringWithFormat:@"%@.%@", appName, classNameWithoutS];
		if (testClassName(predictedClassName)) { return testClassName(predictedClassName); }
	}
	
	// EX: if keyword is "addresses" try to find a class named "Address"
	if ([className hasSuffix:@"es"])
	{
		NSString *classNameWithoutEs = [className substringToIndex:className.length-2];
		
		predictedClassName = [NSString stringWithFormat:@"%@", classNameWithoutEs];
		if (testClassName(predictedClassName)) { return testClassName(predictedClassName); }
		
		predictedClassName = [NSString stringWithFormat:@"%@.%@", appName, classNameWithoutEs];
		if (testClassName(predictedClassName)) { return testClassName(predictedClassName); }
	}
	
	return nil;
}

- (NSDate *)dateFromString:(NSString *)string forProperty:(NSString *)property andClass:(Class)class
{
	NSDate *date;
	NSDateFormatter *customDateFormatter = [self.mappingProvider dateFormatterForClass:class andPropertyKey:property];
	
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
	if (!_commonDateFormaters)
	{
		_commonDateFormaters = [NSMutableArray array];
		
		NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
		[formatter1 setDateFormat:@"yyyy-MM-dd"];
		[_commonDateFormaters addObject:formatter1];
		
		NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
		[formatter2 setDateFormat:@"MM/dd/yyyy"];
		[_commonDateFormaters addObject:formatter2];
		
		NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
		[formatter3 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ"];
		[_commonDateFormaters addObject:formatter3];
		
		NSDateFormatter *formatter4 = [[NSDateFormatter alloc] init];
		[formatter4 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		[_commonDateFormaters addObject:formatter4];
		
		NSDateFormatter *formatter5 = [[NSDateFormatter alloc] init];
		[formatter5 setDateFormat:@"MM/dd/yyyy HH:mm:ss aaa"];
		[_commonDateFormaters addObject:formatter5];
		
		NSDateFormatter *formatter6 = [[NSDateFormatter alloc] init];
		[formatter6 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
		[_commonDateFormaters addObject:formatter6];
	}
	
	return _commonDateFormaters;
}

- (NSString *)typeForProperty:(NSString *)property andClass:(Class)class
{
	NSString *key = [NSString stringWithFormat:@"%@.%@", NSStringFromClass(class), property];
	
	if (self.mappedPropertyNames[key]) {
		return self.mappedPropertyNames[key];
	}
	
	const char *type = property_getAttributes(class_getProperty(class, [property UTF8String]));
	NSString *typeString = [NSString stringWithUTF8String:type];
	NSArray *attributes = [typeString componentsSeparatedByString:@","];
	NSString *typeAttribute = [attributes objectAtIndex:0];
	NSString *className = [[[typeAttribute substringFromIndex:1]
							stringByReplacingOccurrencesOfString:@"@" withString:@""]
						   stringByReplacingOccurrencesOfString:@"\"" withString:@""];
	
	if (className) {
		self.mappedPropertyNames[key] = className;
	}
	
	return className;
}

@end
