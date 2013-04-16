//
//  NSDictionary+ObjectMapper.m
//  OCMapper
//
//  Created by Aryan Gh on 4/14/13.
//  Copyright (c) 2013 Aryan Gh. All rights reserved.
//

#import "NSDictionary+ObjectMapper.h"

@implementation NSDictionary (ObjectMapper)

- (id)objectForClass:(Class)class
{
	return [[ObjectMapper sharedInstance] objectFromSource:self toInstanceOfClass:class];
}

@end
