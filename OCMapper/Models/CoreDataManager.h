//
//  CoreDataManager.h
//  OCMapper
//
//  Created by Aryan Gh on 4/16/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (CoreDataManager *)sharedManager;
- (id)getInstanceForEntity:(NSString *)entity;
- (id)getInstanceWithEntity:(NSString *)entity andPredicate:(NSPredicate *)predicate;
- (void)deleteManageObject:(id)object;
- (void)saveContext;
- (NSArray *)getInstancesWithEntity:(NSString *)entity
						  predicate:(NSPredicate *)predicate
					 sortDescriptor:(NSSortDescriptor *)sortDescriptor
						   andLimit:(NSInteger)limit;

@end
