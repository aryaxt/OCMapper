//
//  ObjectMapper.m
//  OCMapper
//
//  Created by Aryan Gh on 4/14/13.
//  Copyright (c) 2013 Aryan Gh. All rights reserved.
//

#import "ObjectMapper.h"

#define KEY_FOR_ARRAY_OF_OBJECT_MAPPING_INFOS @"objectMappingInfos"

@interface ObjectMapper()
@property (nonatomic, strong) NSMutableDictionary *mappingDictionary;
@property (nonatomic, strong) NSMutableDictionary *dateFormatterDictionary;
@property (nonatomic, strong) NSMutableArray *commonDateFormaters;
@end

@implementation ObjectMapper
@synthesize mappingDictionary;
@synthesize dateFormatterDictionary;
@synthesize defaultDateFormatter;
@synthesize commonDateFormaters;

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
		self.mappingDictionary = [NSMutableDictionary dictionary];
	}
	
	return self;
}

#pragma mark - Public Methods -

- (void)mapFromDictionaryKey:(NSString *)source toPropertyKey:(NSString *)propertyKey withObjectType:(Class)objectType forClass:(Class)class
{
	NSMutableDictionary *mappingForClass = [self.mappingDictionary objectForKey:NSStringFromClass(class)];
	
	if (!mappingForClass)
	{
		mappingForClass = [NSMutableDictionary dictionary];
		[mappingForClass setObject:[NSMutableArray array] forKey:KEY_FOR_ARRAY_OF_OBJECT_MAPPING_INFOS];
	}
	
	NSMutableArray *objectMappingInfos = [mappingForClass objectForKey:KEY_FOR_ARRAY_OF_OBJECT_MAPPING_INFOS];
	ObjectMappingInfo *info = [[ObjectMappingInfo alloc] initWithDictionaryKey:source propertyKey:propertyKey andObjectType:objectType];
	[objectMappingInfos addObject:info];
	
	[self.mappingDictionary setObject:mappingForClass forKey:NSStringFromClass(class)];
}

- (void)mapFromDictionaryKey:(NSString *)dictionaryKey toPropertyKey:(NSString *)propertyKey forClass:(Class)class
{
	[self mapFromDictionaryKey:dictionaryKey toPropertyKey:propertyKey withObjectType:nil forClass:class];
}

- (id)objectFromSource:(id)source toInstanceOfClass:(Class)class
{
	if ([source isKindOfClass:[NSDictionary class]])
	{
		return [self processDictionary:source forClass:class];
	}
	else if ([source isKindOfClass:[NSArray class]])
	{
		return [self processArray:source forClass:class];
	}
	else
	{
		return source;
	}
}

- (void)setDateFormatter:(NSDateFormatter *)dateFormatter forProperty:(NSString *)property andClass:(Class)class
{
	if (!dateFormatterDictionary)
	{
		dateFormatterDictionary = [[NSMutableDictionary alloc] init];
	}
	
	[self.dateFormatterDictionary setObject:dateFormatter forKey:[NSString stringWithFormat:@"%@-%@", NSStringFromClass(class), property]];
}

#pragma mark - Private Methods -

- (NSDateFormatter *)dateFormatterForProperty:(NSString *)property andClass:(Class)class
{
	return [self.dateFormatterDictionary objectForKey:[NSString stringWithFormat:@"%@-%@", NSStringFromClass(class), property]];
}

- (id)processDictionary:(NSDictionary *)source forClass:(Class)class
{
	id object = [[class alloc] init];
	
	for (NSString *key in source)
	{
		ObjectMappingInfo *mappingInfo = [self mappingInfoByDictionaryKey:key forClass:class];
		id value = [source objectForKey:(NSString *)key];
		NSString *propertyName;
		Class objectType;
		id nestedObject;
		
		if (mappingInfo)
		{
			propertyName = mappingInfo.propertyKey;
			objectType = mappingInfo.objectType;
		}
		else
		{
			propertyName = key;
			objectType = [self classFromString:key];
			
			if (!objectType && key.length && [[key substringFromIndex:key.length-1] isEqual:@"s"])
				objectType = [self classFromString:[key substringToIndex:key.length-1]];
		}
		
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
			if ([[self typeForProperty:propertyName andClass:class] rangeOfString:@"NSDate"].length)
			{
				nestedObject = [self dateFromString:value forProperty:propertyName andClass:class];
			}
			else
			{
				nestedObject = value;
			}
		}
		
		if ([object respondsToSelector:NSSelectorFromString(propertyName)])
		{
			[object setValue:nestedObject forKey:propertyName];
		}
	}
	
	return object;
}

- (id)processArray:(NSArray *)value forClass:(Class)class
{
	NSMutableArray *nestedArray = [NSMutableArray array];
	
	for (id objectInArray in value)
	{
		id nestedObject = [self objectFromSource:objectInArray toInstanceOfClass:class];
		
		if (nestedObject)
			[nestedArray addObject:nestedObject];
	}

	return nestedArray;
}

- (Class)classFromString:(NSString *)className
{
	if (NSClassFromString(className))
		return NSClassFromString(className);
	
	if (NSClassFromString([className capitalizedString]))
		return NSClassFromString([className capitalizedString]);
	
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
			Class class = classes[i];
			
			if ([[NSStringFromClass(class) lowercaseString] isEqual:[className lowercaseString]])
				return class;
		}
	}
	
	return nil;
}

- (ObjectMappingInfo *)mappingInfoByDictionaryKey:(NSString *)dictionaryKey forClass:(Class)class
{
	NSMutableArray *mappingInfos = [[self.mappingDictionary objectForKey:NSStringFromClass(class)] objectForKey:KEY_FOR_ARRAY_OF_OBJECT_MAPPING_INFOS];
	
	for (ObjectMappingInfo *info in mappingInfos)
	{
		if ([info.dictionaryKey isEqual:dictionaryKey])
			return info;
	}
	
	return nil;
}

- (NSDate *)dateFromString:(NSString *)string forProperty:(NSString *)property andClass:(Class)class
{
	NSDate *date;
	NSDateFormatter *customDateFormatter = [self dateFormatterForProperty:property andClass:class];
	
	if (customDateFormatter)
	{
		date = [customDateFormatter dateFromString:string];
	}
	if (self.defaultDateFormatter)
	{
		date = [self.defaultDateFormatter dateFromString:string];
	}
	
	if (!date)
	{
		
		for (NSDateFormatter *dateFormatter in self.commonDateFormaters)
		{
			date = [dateFormatter dateFromString:string];
			
			if (date)
				return date;
		}
	}
	
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
	NSString *propertyType = [typeAttribute substringFromIndex:1];
	const char *rawPropertyType = [propertyType UTF8String];
	return [NSString stringWithFormat:@"%s" , rawPropertyType];
}

@end
