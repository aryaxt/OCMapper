//
//  PLISTMappingProvider.m
//  OCMapper
//
//  Created by Aryan Gh on 4/23/13.
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

#import "PLISTMappingProvider.h"

#define PROPERTY_KEY_KEY	@"PropertyKey"
#define DICTIONARY_KEY_KEY	@"DictionaryKey"
#define DATEFORMAT_KEY		@"DateFormat"
#define TIME_ZONE_KEY		@"TimeZone"
#define OBJECT_TYPE_KEY		@"ObjectType"

@interface PLISTMappingProvider()
@property (nonatomic, strong) NSMutableDictionary *mappingDictionary;
@property (nonatomic, strong) NSMutableDictionary *dateFormatterDictionary;
@end

@implementation PLISTMappingProvider
@synthesize mappingDictionary;
@synthesize dateFormatterDictionary;

- (id)initWithFileName:(NSString *)fileName
{
	if (self = [super init])
	{
		self.mappingDictionary = [NSMutableDictionary dictionary];
		self.mappingDictionary = [NSMutableDictionary dictionary];
		
		NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
		NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
		[self populateMappingDictionaryFromDictionry:dictionary];
	}
	
	return self;
}

#pragma mark - private Methods -

- (void)populateMappingDictionaryFromDictionry:(NSDictionary *)dictionary
{	
	for (NSString *classString in dictionary)
	{
		Class class = NSClassFromString(classString);
		NSDictionary *classDictionary = [dictionary objectForKey:classString];
		
		for (NSDictionary *dict in classDictionary)
		{
			NSString *propertyKey = [dict objectForKey:PROPERTY_KEY_KEY];
			NSString *dictionaryKey = [dict objectForKey:DICTIONARY_KEY_KEY];
			NSString *dateFormatString = [dict objectForKey:PROPERTY_KEY_KEY];
			NSString *timeZone = [dict objectForKey:PROPERTY_KEY_KEY];
			Class objectType = NSClassFromString([dict objectForKey:OBJECT_TYPE_KEY]);
			NSDateFormatter *dateFormatter;
			
			if (dateFormatString.length > 0)
			{
				dateFormatter = [[NSDateFormatter alloc] init];
				[dateFormatter setDateFormat:dateFormatString];
				
				if (timeZone.length > 0)
					[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:timeZone]];
				
				NSString *key = [self uniqueKeyForClass:class andKey:propertyKey];
				[self.dateFormatterDictionary setObject:dateFormatter forKey:key];
			}
			
			ObjectMappingInfo *mappingInfo = [[ObjectMappingInfo alloc] initWithDictionaryKey:dictionaryKey propertyKey:propertyKey andObjectType:objectType];
			
			[self.mappingDictionary setObject:mappingInfo forKey:[self uniqueKeyForClass:class andKey:dictionaryKey]];
		}
	}
}

- (NSString *)uniqueKeyForClass:(Class)class andKey:(NSString *)key
{
	return [[NSString stringWithFormat:@"%@-%@", NSStringFromClass(class), key] lowercaseString];
}

#pragma mark - MappingProvider Methods -

- (ObjectMappingInfo *)mappingInfoForClass:(Class)class andDictionaryKey:(NSString *)source
{
	NSString *key = [self uniqueKeyForClass:class andKey:source];
	return [self.mappingDictionary objectForKey:key];
}

- (NSDateFormatter *)dateFormatterForClass:(Class)class andProperty:(NSString *)property
{
	NSString *key = [self uniqueKeyForClass:class andKey:property];
	return [self.dateFormatterDictionary objectForKey:key];
}

@end
