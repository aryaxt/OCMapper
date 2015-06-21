//
//  ManagedObjectInstanceProvider.m
//  OCMapper
//
//  Created by Aryan Gh on 4/20/13.
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

#import "ManagedObjectInstanceProvider.h"

@interface UpsertInfo : NSObject
@property (nonatomic, strong) NSArray *keys;
@property (nonatomic, assign) UpsertMode upsertMode;
@end
@implementation UpsertInfo
@end

@interface ManagedObjectInstanceProvider()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableDictionary *uniqueKeysDictionary;
@end

@implementation ManagedObjectInstanceProvider

#pragma mark - Initialization -

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
	if (self = [super init])
	{
		self.managedObjectContext = aManagedObjectContext;
		self.uniqueKeysDictionary = [NSMutableDictionary dictionary];
	}
	
	return self;
}

- (id)init
{
	@throw ([NSException exceptionWithName:@"InvalidInitializer"
									reason:@"Use initWithManagedObjectContext to initialize this provider"
								  userInfo:nil]);
}

#pragma mark - Public Methods -

- (BOOL)canHandleClass:(Class)class
{
	return ([class isSubclassOfClass:NSManagedObject.class]) ? YES : NO;
}

- (void)setUniqueKeys:(NSArray *)keys forClass:(Class)class withUpsertMode:(UpsertMode)upsertMode
{
	for (id key in keys)
	{
		if (![key isKindOfClass:[NSString class]])
			@throw ([NSException exceptionWithName:@"InvalidArgumentException" reason:@"Method setUniqueKeys takes string only" userInfo:nil]);
	}
	
	UpsertInfo *upsertInfo = [[UpsertInfo alloc] init];
	upsertInfo.keys = keys;
	upsertInfo.upsertMode = upsertMode;
	
	[self.uniqueKeysDictionary setObject:upsertInfo forKey:NSStringFromClass(class)];
}

#pragma mark - InstanceProvider Methods -

- (id)emptyInstanceForClass:(Class)class
{
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(class) inManagedObjectContext:self.managedObjectContext];
	return (entity) ? [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext] : nil;
}

- (id)emptyCollectionInstance
{
	return [NSMutableSet set];
}

- (id)upsertObject:(NSManagedObject *)object error:(NSError **)error
{
	UpsertInfo *upsertInfo = [self.uniqueKeysDictionary objectForKey:NSStringFromClass([object class])];
	
	if (!upsertInfo || !upsertInfo.keys.count)
		return object;
	
	NSMutableArray *predicates = [NSMutableArray array];
	[predicates addObject:[NSPredicate predicateWithFormat:@"SELF != %@", object]];
	
	for (int i=0 ; i<upsertInfo.keys.count ; i++)
	{
		NSString *key = [upsertInfo.keys objectAtIndex:i];
		id value = [object valueForKey:key];
		
		if (key && value)
		{
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", key, value];
			[predicates addObject:predicate];
		}
		else
		{
			*error = [NSError errorWithDomain:[NSString stringWithFormat:@"Value for property '%@' is null. Keys should not be nullable", key] code:0 userInfo:nil];
			return object;
		}
	}
	
	NSPredicate *compundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:NSStringFromClass([object class]) inManagedObjectContext:self.managedObjectContext]];
	[request setPredicate:compundPredicate];
	
	NSError *fetchError;
	NSArray *existingObjects = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
	
	if (fetchError)
	{
		*error = fetchError;
		return object;
	}
	else
	{
		if (existingObjects.count == 0)
		{
			return object;
		}
		else if (existingObjects.count == 1)
		{
			if (upsertInfo.upsertMode == UpsertModeUpdateExistingObject)
			{
				NSManagedObject *existingObject = [existingObjects firstObject];
				
				for (NSAttributeDescription *attributeDescription in existingObject.entity.properties)
				{
					[existingObject setValue:[object valueForKey:attributeDescription.name] forKey:attributeDescription.name];
				}
				
				[self.managedObjectContext deleteObject:object];
				return existingObject;
			}
			else if (upsertInfo.upsertMode == UpsertModePurgeExistingObject)
			{
				NSManagedObject *existingObject = [existingObjects firstObject];
				[self.managedObjectContext deleteObject:existingObject];
				return object;
			}
			else
			{
				*error = [NSError errorWithDomain:[NSString stringWithFormat:@"Invalid upsertMode for class (%@)", NSStringFromClass([object class])] code:0 userInfo:nil];
				return object;
			}
		}
		else
		{
			*error = [NSError errorWithDomain:@"Multiple instances were found based on given key(s)" code:0 userInfo:nil];
			return object;
		}
	}
}

- (NSString *)propertyNameForObject:(NSManagedObject *)object byCaseInsensitivePropertyName:(NSString *)caseInsensitivePropertyName
{
	// Support underscore case (EX: map first_name to firstName)
	caseInsensitivePropertyName = [caseInsensitivePropertyName stringByReplacingOccurrencesOfString:@"_" withString:@""];
	
	for (NSAttributeDescription *attributeDescription in object.entity.properties)
	{
		if ([[attributeDescription.name lowercaseString] isEqual:[caseInsensitivePropertyName lowercaseString]])
			return attributeDescription.name;
	}
	
	return nil;
}

@end
