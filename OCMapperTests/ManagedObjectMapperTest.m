//
//  ManagedObjectMapperTest.m
//  OCMapper
//
//  Created by Aryan Gh on 4/16/13.
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

#import "ManagedObjectMapperTest.h"
#import "User.h"
#import	"CDUser.h"
#import "CDAddress.h"
#import "CDPost.h"
#import "CDSpecialUser.h"

@implementation ManagedObjectMapperTest

#pragma mark - Setup & Teardown -

- (void)setUp
{
    [super setUp];
	
	self.coreDataManager = [[CoreDataManager alloc] init];
	self.instanceProvider = [[ManagedObjectInstanceProvider alloc]
													   initWithManagedObjectContext:self.coreDataManager.managedObjectContext];
	
	self.mappingProvider = [[InCodeMappingProvider alloc] init];
	
	self.mapper = [[ObjectMapper alloc] init];
	self.mapper.mappingProvider = self.mappingProvider;
	[self.mapper addInstanceProvider:self.instanceProvider];
}

- (void)tearDown
{
	self.mapper = nil;
	self.mappingProvider = nil;
	self.instanceProvider = nil;
	self.coreDataManager = nil;
	
    [super tearDown];
}

#pragma mark - Tests -

- (void)testSimpleMapping
{
	NSString *firstName = @"Aryan";
	NSNumber *age = @26;
	NSString *dateString = @"06/21/2013";
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MM/dd/yyyy"];
	NSDate *expectedDate = [dateFormatter dateFromString:dateString];
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:dateString forKey:@"dateOfBirth"];
	[userDictionary setObject:firstName forKey:@"firstName"];
	[userDictionary setObject:age forKey:@"age"];
	
	CDUser *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[CDUser class]];
	XCTAssertTrue([user.dateOfBirth isEqual:expectedDate], @"date did not populate correctly");
	XCTAssertTrue([user.age isEqual:age], @"date did not populate correctly");
	XCTAssertTrue([user.firstName isEqual:firstName], @"date did not populate correctly");
}

- (void)testNestedMapping
{
	[self.mappingProvider mapFromDictionaryKey:@"address" toPropertyKey:@"address" withObjectType:[CDAddress class] forClass:[CDUser class]];
	
	NSString *city = @"San Diego";
	NSString *country = @"US";
	
	NSMutableDictionary *addressDict = [NSMutableDictionary dictionary];
	[addressDict setObject:city forKey:@"city"];
	[addressDict setObject:country forKey:@"country"];
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:addressDict forKey:@"address"];
	
	CDUser *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[CDUser class]];
	XCTAssertTrue([user.address.city isEqual:city], @"date did not populate correctly");
	XCTAssertTrue([user.address.country isEqual:country], @"date did not populate correctly");
}

- (void)testNestedArrayMapping
{
	[self.mappingProvider mapFromDictionaryKey:@"posts" toPropertyKey:@"posts" withObjectType:[CDPost class] forClass:[CDUser class]];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MM/dd/yyyy"];
	
	NSString *title1 = @"title 1";
	NSString *date1 = @"06/21/2013";
	
	NSString *title2 = @"title 2";
	NSString *date2 = @"02/16/2012";
	
	NSMutableDictionary *postDictionary = [NSMutableDictionary dictionary];
	[postDictionary setObject:title1 forKey:@"title"];
	[postDictionary setObject:date1 forKey:@"postedDate"];
	
	NSMutableDictionary *postDictionary2 = [NSMutableDictionary dictionary];
	[postDictionary2 setObject:title2 forKey:@"title"];
	[postDictionary2 setObject:date2 forKey:@"postedDate"];
	
	NSMutableDictionary *userDict = [NSMutableDictionary dictionary];
	[userDict setObject:@[postDictionary2, postDictionary] forKey:@"posts"];
	
	CDUser *user = [self.mapper objectFromSource:userDict toInstanceOfClass:[CDUser class]];
	user = nil;
}

- (void)testShouldMapPropertiesInSuperClass
{
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:@"aryan" forKey:@"firstName"];
	[userDictionary setObject:@"stealth" forKey:@"power"];
	
	CDSpecialUser *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[CDSpecialUser class]];
	XCTAssertTrue([user.firstName isEqual:[userDictionary objectForKey:@"firstName"]], @"date did not populate correctly");
	XCTAssertTrue([user.power isEqual:[userDictionary objectForKey:@"power"]], @"date did not populate correctly");
}

- (void)testShouldPopulateDictionaryWithPropertyInSuperClass
{
	CDSpecialUser *user = [NSEntityDescription insertNewObjectForEntityForName:@"CDSpecialUser"
														inManagedObjectContext:self.coreDataManager.managedObjectContext];
	user.power = @"stealth";
	user.firstName = @"Aryan";
	
	NSDictionary *dictionary = [self.mapper dictionaryFromObject:user];
	XCTAssertTrue([user.firstName isEqual:[dictionary objectForKey:@"first_name"]], @"Did Not populate dictionary properly");
	XCTAssertTrue([user.power isEqual:[dictionary objectForKey:@"power"]], @"Did Not populate dictionary properly");
}

- (void)testShouldUpdateExistingManagedObjectBasedOnSingleProvidedKeyInUpsertModelUpdateExisting
{
	[self.instanceProvider setUniqueKeys:@[@"userId"] forClass:[CDSpecialUser class] withUpsertMode:UpsertModeUpdateExistingObject];
	
	CDSpecialUser *originalUser = [NSEntityDescription insertNewObjectForEntityForName:@"CDSpecialUser"
														inManagedObjectContext:self.coreDataManager.managedObjectContext];
	originalUser.userId = @1;
	originalUser.power = @"stealth1";
	originalUser.firstName = @"aryan1";
	[self.coreDataManager.managedObjectContext save:nil];
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:@1 forKey:@"userId"];
	[userDictionary setObject:@"aryan2" forKey:@"firstName"];
	[userDictionary setObject:@"stealth2" forKey:@"power"];
	
	CDSpecialUser *newUser = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[CDSpecialUser class]];
	XCTAssertTrue([originalUser.objectID isEqual:newUser.objectID], @"Did Not update existing ManagedObject");
	XCTAssertTrue([originalUser.firstName isEqual:newUser.firstName], @"Did Not update existing ManagedObject");
	XCTAssertTrue([originalUser.power isEqual:newUser.power], @"Did Not update existing ManagedObject");
}

- (void)testShouldUpdateExistingManagedObjectBasedOnMultipleProvidedKeyInUpsertModelUpdateExisting
{
	[self.instanceProvider setUniqueKeys:@[@"userId", @"age"] forClass:[CDSpecialUser class] withUpsertMode:UpsertModeUpdateExistingObject];

	CDSpecialUser *originalUser = [NSEntityDescription insertNewObjectForEntityForName:@"CDSpecialUser"
																inManagedObjectContext:self.coreDataManager.managedObjectContext];
	originalUser.userId = @1;
	originalUser.age = @1;
	originalUser.power = @"stealth1";
	originalUser.firstName = @"aryan1";
	[self.coreDataManager.managedObjectContext save:nil];
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:@1 forKey:@"userId"];
	[userDictionary setObject:@1 forKey:@"age"];
	[userDictionary setObject:@"aryan2" forKey:@"firstName"];
	[userDictionary setObject:@"stealth2" forKey:@"power"];
	
	CDSpecialUser *newUser = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[CDSpecialUser class]];
	XCTAssertTrue([originalUser.objectID isEqual:newUser.objectID], @"Did Not update existing ManagedObject");
	XCTAssertTrue([originalUser.firstName isEqual:newUser.firstName], @"Did Not update existing ManagedObject");
	XCTAssertTrue([originalUser.power isEqual:newUser.power], @"Did Not update existing ManagedObject");
}

- (void)testShouldNotUpdateExistingManagedObjectBasedOnMultipleProvidedKeyWhenOneKeyIsDifferentInUpsertModelUpdateExisting
{
	[self.instanceProvider setUniqueKeys:@[@"userId", @"age"] forClass:[CDSpecialUser class] withUpsertMode:UpsertModeUpdateExistingObject];
	
	CDSpecialUser *originalUser = [NSEntityDescription insertNewObjectForEntityForName:@"CDSpecialUser"
																inManagedObjectContext:self.coreDataManager.managedObjectContext];
	originalUser.userId = @1;
	originalUser.age = @2;
	originalUser.power = @"stealth1";
	originalUser.firstName = @"aryan1";
	[self.coreDataManager.managedObjectContext save:nil];
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:@1 forKey:@"userId"];
	[userDictionary setObject:@1 forKey:@"age"];
	[userDictionary setObject:@"aryan2" forKey:@"firstName"];
	[userDictionary setObject:@"stealth2" forKey:@"power"];
	
	CDSpecialUser *newUser = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[CDSpecialUser class]];
	XCTAssertTrue(![originalUser.objectID isEqual:newUser.objectID], @"Did Not update existing ManagedObject");
	XCTAssertTrue(![originalUser.firstName isEqual:newUser.firstName], @"Did Not update existing ManagedObject");
	XCTAssertTrue(![originalUser.power isEqual:newUser.power], @"Did Not update existing ManagedObject");
}

- (void)testShouldNotUpdateExistingManagedObjectBasedOnSingleProvidedKeyWhenKeysAreDifferentInUpsertModelUpdateExisting
{
	[self.instanceProvider setUniqueKeys:@[@"userId"] forClass:[CDSpecialUser class] withUpsertMode:UpsertModeUpdateExistingObject];
	
	CDSpecialUser *originalUser = [NSEntityDescription insertNewObjectForEntityForName:@"CDSpecialUser"
																inManagedObjectContext:self.coreDataManager.managedObjectContext];
	originalUser.userId = @1;
	originalUser.power = @"stealth1";
	originalUser.firstName = @"aryan1";
	[self.coreDataManager.managedObjectContext save:nil];
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:@2 forKey:@"userId"];
	[userDictionary setObject:@"aryan2" forKey:@"firstName"];
	[userDictionary setObject:@"stealth2" forKey:@"power"];
	
	CDSpecialUser *newUser = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[CDSpecialUser class]];
	XCTAssertTrue(![originalUser.objectID isEqual:newUser.objectID], @"Did Not update existing ManagedObject");
	XCTAssertTrue(![originalUser.firstName isEqual:newUser.firstName], @"Did Not update existing ManagedObject");
	XCTAssertTrue(![originalUser.power isEqual:newUser.power], @"Did Not update existing ManagedObject");
}

- (void)testNumberOfCreatedManagedObjectsOnUpdateForUpsertModeUpdateExisting
{
	[self.instanceProvider setUniqueKeys:@[@"userId"] forClass:[CDSpecialUser class] withUpsertMode:UpsertModeUpdateExistingObject];
	[self.instanceProvider setUniqueKeys:@[@"addressId"] forClass:[CDAddress class] withUpsertMode:UpsertModeUpdateExistingObject];
	[self.mappingProvider mapFromDictionaryKey:@"address" toPropertyKey:@"address" withObjectType:[CDAddress class] forClass:[CDSpecialUser class]];
	
	CDSpecialUser *originalUser = [NSEntityDescription insertNewObjectForEntityForName:@"CDSpecialUser"
																inManagedObjectContext:self.coreDataManager.managedObjectContext];
	originalUser.userId = @1;
	
	CDAddress *originalAddress = [NSEntityDescription insertNewObjectForEntityForName:@"CDAddress"
																inManagedObjectContext:self.coreDataManager.managedObjectContext];
	originalAddress.addressId = @1;
	originalUser.address = originalAddress;
	
	[self.coreDataManager.managedObjectContext save:nil];
	
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:@1 forKey:@"userId"];
	[userDictionary setObject:@"ary" forKey:@"firstName"];
	NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];
	[addressDictionary setObject:@1 forKey:@"addressId"];
	[addressDictionary setObject:@"San Diego" forKey:@"city"];
	[userDictionary setObject:addressDictionary forKey:@"address"];
	
	CDSpecialUser *newUser = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[CDSpecialUser class]];
	newUser = nil; /*Just avoiding warnings*/
	
	[self.coreDataManager.managedObjectContext save:nil];
	
	NSFetchRequest *userRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDSpecialUser"];
	NSFetchRequest *addressRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDAddress"];
	
	NSArray *users = [self.coreDataManager.managedObjectContext executeFetchRequest:userRequest error:nil];
	NSArray *addresses = [self.coreDataManager.managedObjectContext executeFetchRequest:addressRequest error:nil];
	
	XCTAssertTrue(users.count == 1, @"Did Not update existing ManagedObject");
	XCTAssertTrue(addresses.count == 1, @"Did Not update existing ManagedObject");
}

- (void)testNumberOfCreatedManagedObjectsOnNonUpdateForUpsertModeUpdateExisting
{
	[self.mappingProvider mapFromDictionaryKey:@"address" toPropertyKey:@"address" withObjectType:[CDAddress class] forClass:[CDSpecialUser class]];
	
	CDSpecialUser *originalUser = [NSEntityDescription insertNewObjectForEntityForName:@"CDSpecialUser"
																inManagedObjectContext:self.coreDataManager.managedObjectContext];
	originalUser.userId = @1;
	
	CDAddress *originalAddress = [NSEntityDescription insertNewObjectForEntityForName:@"CDAddress"
															   inManagedObjectContext:self.coreDataManager.managedObjectContext];
	originalAddress.addressId = @1;
	originalUser.address = originalAddress;
	
	[self.coreDataManager.managedObjectContext save:nil];
	
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:@1 forKey:@"userId"];
	[userDictionary setObject:@"ary" forKey:@"firstName"];
	NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];
	[addressDictionary setObject:@1 forKey:@"addressId"];
	[addressDictionary setObject:@"San Diego" forKey:@"city"];
	[userDictionary setObject:addressDictionary forKey:@"address"];
	
	CDSpecialUser *newUser = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[CDSpecialUser class]];
	newUser = nil; /*Just avoiding warnings*/
	
	[self.coreDataManager.managedObjectContext save:nil];
	
	NSFetchRequest *userRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDSpecialUser"];
	NSFetchRequest *addressRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDAddress"];
	
	NSArray *users = [self.coreDataManager.managedObjectContext executeFetchRequest:userRequest error:nil];
	NSArray *addresses = [self.coreDataManager.managedObjectContext executeFetchRequest:addressRequest error:nil];
	
	XCTAssertTrue(users.count == 2, @"Did Not update existing ManagedObject");
	XCTAssertTrue(addresses.count == 2, @"Did Not update existing ManagedObject");
}

- (void)testNumberOfCreatedManagedObjectsOnUpdateForUpsertModePurgeExisting
{
	[self.instanceProvider setUniqueKeys:@[@"userId"] forClass:[CDSpecialUser class] withUpsertMode:UpsertModePurgeExistingObject];
	[self.instanceProvider setUniqueKeys:@[@"addressId"] forClass:[CDAddress class] withUpsertMode:UpsertModePurgeExistingObject];
	[self.mappingProvider mapFromDictionaryKey:@"address" toPropertyKey:@"address" withObjectType:[CDAddress class] forClass:[CDSpecialUser class]];
	
	CDSpecialUser *originalUser = [NSEntityDescription insertNewObjectForEntityForName:@"CDSpecialUser"
																inManagedObjectContext:self.coreDataManager.managedObjectContext];
	originalUser.userId = @1;
	
	CDAddress *originalAddress = [NSEntityDescription insertNewObjectForEntityForName:@"CDAddress"
															   inManagedObjectContext:self.coreDataManager.managedObjectContext];
	originalAddress.addressId = @1;
	originalUser.address = originalAddress;
	
	[self.coreDataManager.managedObjectContext save:nil];
	
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:@1 forKey:@"userId"];
	[userDictionary setObject:@"ary" forKey:@"firstName"];
	NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];
	[addressDictionary setObject:@1 forKey:@"addressId"];
	[addressDictionary setObject:@"San Diego" forKey:@"city"];
	[userDictionary setObject:addressDictionary forKey:@"address"];
	
	CDSpecialUser *newUser = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[CDSpecialUser class]];
	newUser = nil; /*Just avoiding warnings*/
	
	[self.coreDataManager.managedObjectContext save:nil];
	
	NSFetchRequest *userRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDSpecialUser"];
	NSFetchRequest *addressRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDAddress"];
	
	NSArray *users = [self.coreDataManager.managedObjectContext executeFetchRequest:userRequest error:nil];
	NSArray *addresses = [self.coreDataManager.managedObjectContext executeFetchRequest:addressRequest error:nil];
	
	XCTAssertTrue(users.count == 1, @"Did Not update existing ManagedObject");
	XCTAssertTrue(addresses.count == 1, @"Did Not update existing ManagedObject");
}

- (void)testNumberOfCreatedManagedObjectsOnNonUpdateForUpsertModePurgeExisting
{
	[self.mappingProvider mapFromDictionaryKey:@"address" toPropertyKey:@"address" withObjectType:[CDAddress class] forClass:[CDSpecialUser class]];
	
	CDSpecialUser *originalUser = [NSEntityDescription insertNewObjectForEntityForName:@"CDSpecialUser"
																inManagedObjectContext:self.coreDataManager.managedObjectContext];
	originalUser.userId = @1;
	
	CDAddress *originalAddress = [NSEntityDescription insertNewObjectForEntityForName:@"CDAddress"
															   inManagedObjectContext:self.coreDataManager.managedObjectContext];
	originalAddress.addressId = @1;
	originalUser.address = originalAddress;
	
	[self.coreDataManager.managedObjectContext save:nil];
	
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:@1 forKey:@"userId"];
	[userDictionary setObject:@"ary" forKey:@"firstName"];
	NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];
	[addressDictionary setObject:@1 forKey:@"addressId"];
	[addressDictionary setObject:@"San Diego" forKey:@"city"];
	[userDictionary setObject:addressDictionary forKey:@"address"];
	
	CDSpecialUser *newUser = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[CDSpecialUser class]];
	newUser = nil; /*Just avoiding warnings*/
	
	[self.coreDataManager.managedObjectContext save:nil];
	
	NSFetchRequest *userRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDSpecialUser"];
	NSFetchRequest *addressRequest = [NSFetchRequest fetchRequestWithEntityName:@"CDAddress"];
	
	NSArray *users = [self.coreDataManager.managedObjectContext executeFetchRequest:userRequest error:nil];
	NSArray *addresses = [self.coreDataManager.managedObjectContext executeFetchRequest:addressRequest error:nil];
	
	XCTAssertTrue(users.count == 2, @"Did Not update existing ManagedObject");
	XCTAssertTrue(addresses.count == 2, @"Did Not update existing ManagedObject");
}

- (void)testManagedObjectInstanceProviderShouldReturnFalseForNSObjectSubclasses
{
	XCTAssertFalse([self.instanceProvider canHandleClass:User.class]);
}

- (void)testManagedObjectInstanceProviderShouldReturnTrueForNSManagedObjectSubclasses
{
	XCTAssertTrue([self.instanceProvider canHandleClass:CDUser.class]);
}

@end
