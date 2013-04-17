//
//  NSManagedObjectMapper.m
//  OCMapper
//
//  Created by Aryan Gh on 4/16/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "ManagedObjectMapper.h"

@implementation ManagedObjectMapper
@synthesize managedObjectContext;

#pragma mark - Initialization -

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	if (self = [super init])
	{
		self.managedObjectContext = aManagedObjectContext;
	}
	
	return self;
}

#pragma mark - Overriding Methods -

- (id)emptyInstanceFromClass:(Class)class
{
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(class) inManagedObjectContext:self.managedObjectContext];
	return (entity) ? [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext] : nil;
}

- (id)objectFromSource:(id)source toInstanceOfClass:(Class)class
{
	if (!self.managedObjectContext)
		@throw ([NSException exceptionWithName:@"NSManagedObjectContextMissing"
										reason:@"Managed object context must be set on NSManagedObjectMapper before use."
									  userInfo:nil]);
	
	return [super objectFromSource:source toInstanceOfClass:class];
}

- (id)processArray:(NSArray *)value forClass:(Class)class
{
	NSMutableSet *nestedSet = [NSMutableSet set];
	
	for (id objectInArray in value)
	{
		id nestedObject = [self objectFromSource:objectInArray toInstanceOfClass:class];
		
		if (nestedSet)
			[nestedSet addObject:nestedObject];
	}
	
	return nestedSet;
}


@end
