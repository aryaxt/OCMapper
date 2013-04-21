//
//  ObjectMapper.m
//  OCMapper
//
//  Created by Aryan Gh on 4/14/13.
//  Copyright (c) 2013 Aryan Gh. All rights reserved.
//

#import "ObjectMapper.h"

@interface ObjectMapper()
@property (nonatomic, strong) NSMutableDictionary *dateFormatterDictionary;
@property (nonatomic, strong) NSMutableArray *commonDateFormaters;
@end

@implementation ObjectMapper
@synthesize dateFormatterDictionary;
@synthesize defaultDateFormatter;
@synthesize commonDateFormaters;
@synthesize instanceProvider;
@synthesize mappingProvider;

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
		self.mappingProvider = [[InCodeMappintProvider alloc] init];
		self.instanceProvider = [[ObjectInstanceProvider alloc] init];
	}
	
	return self;
}

#pragma mark - Public Methods -

- (void)setDateFormatter:(NSDateFormatter *)dateFormatter forProperty:(NSString *)property andClass:(Class)class
{
	if (!dateFormatterDictionary)
	{
		dateFormatterDictionary = [[NSMutableDictionary alloc] init];
	}
	
	[self.dateFormatterDictionary setObject:dateFormatter forKey:[NSString stringWithFormat:@"%@-%@", NSStringFromClass(class), property]];
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

- (NSDictionary *)dictionaryFromObject:(NSObject *)object
{
	NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([object class], &outCount);
	
    for (i = 0; i < outCount; i++)
	{
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        id propertyValue = [object valueForKey:(NSString *)propertyName];
        if (propertyValue) [props setObject:propertyValue forKey:propertyName];
    }
	
    free(properties);
    return props;
}

#pragma mark - Private Methods -

- (NSDateFormatter *)dateFormatterForProperty:(NSString *)property andClass:(Class)class
{
	return [self.dateFormatterDictionary objectForKey:[NSString stringWithFormat:@"%@-%@", NSStringFromClass(class), property]];
}

- (id)processDictionary:(NSDictionary *)source forClass:(Class)class
{
	id object = [self.instanceProvider emptyInstanceFromClass:class];
	
	for (NSString *key in source)
	{
		ObjectMappingInfo *mappingInfo = [self.mappingProvider mappingInfoForClass:class andDictionaryKey:key];
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
			propertyName = [self.instanceProvider propertyNameForObject:object byCaseInsensitivePropertyName:key];
			
			if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]])
			{
				objectType = [self classFromString:key];
			}
		}
		
		if (class && object && [object respondsToSelector:NSSelectorFromString(propertyName)])
		{
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
				[object setValue:nestedObject forKey:propertyName];
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
	if (NSClassFromString(className))
		return NSClassFromString(className);
	
	if (NSClassFromString([className capitalizedString]))
		return NSClassFromString([className capitalizedString]);
	
	NSString *classNameLowerCase = [className lowercaseString];
	
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
			NSString *thisClassNameLowerCase = [NSStringFromClass(class) lowercaseString];
			
			if ([thisClassNameLowerCase isEqual:classNameLowerCase] ||
				[[NSString stringWithFormat:@"%@s", thisClassNameLowerCase] isEqual:classNameLowerCase] ||
				[[NSString stringWithFormat:@"%@es", thisClassNameLowerCase] isEqual:classNameLowerCase])
				return class;
		}
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
	else if (self.defaultDateFormatter)
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
	return [[[typeAttribute substringFromIndex:1]
			 stringByReplacingOccurrencesOfString:@"@" withString:@""]
			stringByReplacingOccurrencesOfString:@"\"" withString:@""];
}

@end
