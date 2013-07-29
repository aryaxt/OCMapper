//
//  InCodeMappintProvider.m
//  OCMapper
//
//  Created by Aryan Gh on 4/20/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//
// https://github.com/aryaxt/OCMapper
//
// Permission to use, copy, modify and distribute this software and its documentation
// is hereby granted, provided that both the copyright notice and this permission
// notice appear in all copies of the software, derivative works or modified versions,
// and any portions thereof, and that both notices appear in supporting documentation,
// and that credit is given to Aryan Ghassemi in all documents and publicity
// pertaining to direct or indirect use of this code or its derivatives.
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

#import "InCodeMappingProvider.h"

#define KEY_FOR_ARRAY_OF_OBJECT_MAPPING_INFOS @"objectMappingInfos"

@interface InCodeMappingProvider()
@property (nonatomic, strong) NSMutableDictionary *mappingDictionary;
@property (nonatomic, strong) NSMutableDictionary *dateFormatterDictionary;
@end

@implementation InCodeMappingProvider
@synthesize mappingDictionary;
@synthesize dateFormatterDictionary;

#pragma mark - Initialization -

- (id)init
{
	if (self = [super init])
	{
		self.mappingDictionary = [NSMutableDictionary dictionary];
		self.dateFormatterDictionary = [NSMutableDictionary dictionary];
	}
	
	return self;
}

#pragma mark - Public Methods -

- (void)mapFromDictionaryKey:(NSString *)source toPropertyKey:(NSString *)propertyKey withObjectType:(Class)objectType forClass:(Class)class
{
	ObjectMappingInfo *info = [[ObjectMappingInfo alloc] initWithDictionaryKey:source propertyKey:propertyKey andObjectType:objectType];
	NSString *key = [self uniqueKeyForClass:class andKey:source];
	[self.mappingDictionary setObject:info forKey:key];
}

- (void)setDateFormatter:(NSDateFormatter *)dateFormatter forProperty:(NSString *)property andClass:(Class)class
{
	NSString *key = [self uniqueKeyForClass:class andKey:property];
	[self.dateFormatterDictionary setObject:dateFormatter forKey:key];
}

- (void)mapFromDictionaryKey:(NSString *)dictionaryKey toPropertyKey:(NSString *)propertyKey forClass:(Class)class
{
	[self mapFromDictionaryKey:dictionaryKey toPropertyKey:propertyKey withObjectType:nil forClass:class];
}

#pragma mark - public Methods -

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
