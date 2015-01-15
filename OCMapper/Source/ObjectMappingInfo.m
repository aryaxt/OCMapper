//
//  ObjectMapperInfo.m
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

#import "ObjectMappingInfo.h"

@implementation ObjectMappingInfo
@synthesize dictionaryKey;
@synthesize propertyKey;
@synthesize objectType;

#pragma mark - Initialization -

- (id)initWithDictionaryKey:(NSString *)aDictionaryKey propertyKey:(NSString *)aPropertyKey andObjectType:(Class)anObjectType
{
	if (self = [super init])
	{
		self.dictionaryKey = aDictionaryKey;
		self.propertyKey = aPropertyKey;
		self.objectType = anObjectType;
	}
	
	return self;
}

- (id)initWithDictionaryKey:(NSString *)aDictionaryKey propertyKey:(NSString *)aPropertyKey andTransformer:(MappingTransformer)transformer
{
	if (self = [super init])
	{
		self.dictionaryKey = aDictionaryKey;
		self.propertyKey = aPropertyKey;
		self.transformer = transformer;
	}
	
	return self;
}

@end
