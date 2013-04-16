//
//  NSDictionary+ObjectMapper.h
//  OCMapper
//
//  Created by Aryan Gh on 4/14/13.
//  Copyright (c) 2013 Aryan Gh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectMapper.h"

@interface NSDictionary (ObjectMapper)

- (id)objectForClass:(Class)class;

@end
