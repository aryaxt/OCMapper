//
//  NSObject+ObjectMapper.m
//  OCMapper
//
//  Created by Aryan Gh on 4/14/13.
//  Copyright (c) 2013 Aryan Gh. All rights reserved.
//

#import "NSObject+ObjectMapper.h"

@implementation NSObject (ObjectMapper)

+ (id)objectFromDictionary:(NSDictionary *)dictionary
{
	return [[ObjectMapper sharedInstance] objectFromSource:dictionary toInstanceOfClass:[self class]];
}

- (NSDictionary *)dictionary
{
	return [[ObjectMapper sharedInstance] dictionaryFromObject:self];
}

- (NSDictionary *)dictionaryWrappedInParentWithKey:(NSString *)key
{
	return [NSDictionary dictionaryWithObject:[self dictionary] forKey:key];
}

@end
