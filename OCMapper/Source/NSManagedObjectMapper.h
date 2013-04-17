//
//  NSManagedObjectMapper.h
//  OCMapper
//
//  Created by Aryan Gh on 4/16/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "ObjectMapper.h"
#import <CoreData/CoreData.h>

@interface NSManagedObjectMapper : ObjectMapper

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
