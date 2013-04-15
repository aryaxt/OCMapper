//
//  NSDictionary+ObjectMapper.m
//  iFollow
//
//  Created by Aryan Gh on 4/14/13.
//  Copyright (c) 2013 Aryan Gh. All rights reserved.
//

#import "NSDictionary+ObjectMapper.h"

@implementation NSDictionary (ObjectMapper)

- (id)objectForClass:(Class)class
{
	return [[ObjectMapper sharedInstance] objectFromDictionary:self toInstanceOfClass:class];
}

@end
