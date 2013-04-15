//
//  ObjectMapper.m
//  iFollow
//
//  Created by Aryan Gh on 4/14/13.
//  Copyright (c) 2013 Aryan Gh. All rights reserved.
//

#import "ObjectMapper.h"

#define KEY_FOR_ARRAY_OF_OBJECT_MAPPING_INFOS @"objectMappingInfos"

@interface ObjectMapper()
@property (nonatomic, strong) NSMutableDictionary *mappingDictionary;
@end

@implementation ObjectMapper
@synthesize mappingDictionary;

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

- (void)mapFromDictionaryKey:(NSString *)dictionaryKey toPropertyKey:(NSString *)propertyKey withObjectType:(Class)objectType forClass:(Class)class
{
	NSMutableDictionary *mappingForClass = [self.mappingDictionary objectForKey:NSStringFromClass(class)];
	
	if (!mappingForClass)
	{
		mappingForClass = [NSMutableDictionary dictionary];
		[mappingForClass setObject:[NSMutableArray array] forKey:KEY_FOR_ARRAY_OF_OBJECT_MAPPING_INFOS];
	}
	
	NSMutableArray *objectMappingInfos = [mappingForClass objectForKey:KEY_FOR_ARRAY_OF_OBJECT_MAPPING_INFOS];
	ObjectMappingInfo *info = [[ObjectMappingInfo alloc] initWithDictionaryKey:dictionaryKey propertyKey:propertyKey andObjectType:objectType];
	[objectMappingInfos addObject:info];
	
	[self.mappingDictionary setObject:mappingForClass forKey:NSStringFromClass(class)];
}

- (void)mapFromDictionaryKey:(NSString *)dictionaryKey toPropertyKey:(NSString *)propertyKey forClass:(Class)class
{
	[self mapFromDictionaryKey:dictionaryKey toPropertyKey:propertyKey withObjectType:nil forClass:class];
}

- (id)objectFromSource:(NSDictionary *)source toInstanceOfClass:(Class)class
{
	id object = [[class alloc] init];
	
	for (NSString *key in source)
	{
		ObjectMappingInfo *mappingInfo = [self mappingInfoByDictionaryKey:key forClass:class];
		id value = [source objectForKey:(NSString *)key];
		
		if ([value isKindOfClass:[NSDictionary class]])
		{
			if (mappingInfo)
			{
				NSString *propertyName = mappingInfo.propertyKey;
				id nestedObject = [self objectFromSource:value toInstanceOfClass:mappingInfo.objectType];
				
				if ([object respondsToSelector:NSSelectorFromString(propertyName)])
				{
					[object setValue:nestedObject forKey:propertyName];
				}
			}
			else
			{
				NSString *propertyName = key;
				Class nestedClass = [self classFromString:key];
				
				if (nestedClass && [object respondsToSelector:NSSelectorFromString(propertyName)])
				{
					id nestedObject = [self objectFromSource:value toInstanceOfClass:nestedClass];
					[object setValue:nestedObject forKey:propertyName];
				}
			}
		}
		else if ([value isKindOfClass:[NSArray class]])
		{
			NSMutableArray *nestedArray = [NSMutableArray array];

			for (id objectInArray in value)
			{
				id nestedObject = nil;
				
				if (mappingInfo)
				{
					nestedObject = [self objectFromSource:value toInstanceOfClass:mappingInfo.objectType];
				}
				else
				{
					Class nestedClass = [self classFromString:key];
					
					if (!nestedClass && key.length && [[key substringFromIndex:key.length-1] isEqual:@"s"])
						nestedClass = [self classFromString:[key substringToIndex:key.length-1]];
					
					if (nestedClass)
					{
						nestedObject = [self objectFromSource:objectInArray toInstanceOfClass:nestedClass];
					}
				}
				
				if (nestedObject)
					[nestedArray addObject:nestedObject];
			}
			
			NSString *propertyName = (mappingInfo) ? mappingInfo.propertyKey : key;
			
			if ([object respondsToSelector:NSSelectorFromString(propertyName)])
			{
				[object setValue:nestedArray forKey:propertyName];
			}
		}
		else
		{
			NSString *propertyName = (mappingInfo) ? mappingInfo.propertyKey : key;
				
			if ([object respondsToSelector:NSSelectorFromString(propertyName)])
			{
				[object setValue:value forKey:propertyName];
			}
		}
	}
	
	return object;
}

#pragma mark - Private Methods -

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

@end
