//
//  NSDictionary+ObjectMapper.m
//  OCMapper
//
//  Created by Aryan Gh on 4/14/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "NSDictionary+ObjectMapper.h"

@implementation NSDictionary (ObjectMapper)

- (id)objectForClass:(Class)class
{
	return [[ObjectMapper sharedInstance] objectFromSource:self toInstanceOfClass:class];
}

- (NSDictionary *)dictionaryFromObject:(NSObject *)object
{
	return [[ObjectMapper sharedInstance] dictionaryFromObject:object];
}

- (NSDictionary *)dictionaryFromObject:(NSObject *)object wrappedInParentWithKey:(NSString *)key
{
	return [NSDictionary dictionaryWithObject:[self dictionaryFromObject:object] forKey:key];
}

@end
