//
//  ManagedObjectInstanceProvider.m
//  OCMapper
//
//  Created by Aryan Gh on 4/20/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "ManagedObjectInstanceProvider.h"

@implementation ManagedObjectInstanceProvider
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

#pragma mark - InstanceProvider Methods -

- (id)emptyInstanceFromClass:(Class)class
{
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(class) inManagedObjectContext:self.managedObjectContext];
	return (entity) ? [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext] : nil;
}

- (id)emptyInstanceOfCollectionObject
{
	return [NSMutableSet set];
}

- (NSString *)propertyNameForObject:(NSManagedObject *)object byCaseInsensitivePropertyName:(NSString *)caseInsensitivePropertyName
{
	for (NSAttributeDescription *attributeDescription in object.entity.properties)
	{
		if ([[attributeDescription.name lowercaseString] isEqual:[caseInsensitivePropertyName lowercaseString]])
			return attributeDescription.name;
	}
	
	return nil;
}

@end
