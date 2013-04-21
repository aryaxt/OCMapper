//
//  ManagedObjectMapperTest.m
//  OCMapper
//
//  Created by Aryan Gh on 4/16/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "ManagedObjectMapperTest.h"
#import "CoreDataManager.h"
#import	"CDUser.h"
#import "CDAddress.h"
#import "CDPost.h"

@implementation ManagedObjectMapperTest
@synthesize mapper;
@synthesize mappingProvider;

#pragma mark - Setup & Teardown -

- (void)setUp
{
    [super setUp];
	
	CoreDataManager *coreDataManager = [[CoreDataManager alloc] init];
	ManagedObjectInstanceProvider *instanceProvider = [[ManagedObjectInstanceProvider alloc]
													   initWithManagedObjectContext:coreDataManager.managedObjectContext];
	
	self.mappingProvider = [[InCodeMappintProvider alloc] init];
	
	self.mapper = [[ObjectMapper alloc] init];
	self.mapper.mappingProvider = self.mappingProvider;
	self.mapper.instanceProvider = instanceProvider;
}

- (void)tearDown
{
	self.mapper = nil;
	self.mappingProvider = nil;
	
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
	STAssertTrue([user.dateOfBirth isEqual:expectedDate], @"date did not populate correctly");
	STAssertTrue([user.age isEqual:age], @"date did not populate correctly");
	STAssertTrue([user.firstName isEqual:firstName], @"date did not populate correctly");
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
	STAssertTrue([user.address.city isEqual:city], @"date did not populate correctly");
	STAssertTrue([user.address.country isEqual:country], @"date did not populate correctly");
}

- (void)testNestedArrayMapping
{
	[self.mappingProvider mapFromDictionaryKey:@"posts" toPropertyKey:@"posts" withObjectType:[CDPost class] forClass:[CDUser class]];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MM/dd/yyyy"];
	
	NSString *title1 = @"title 1";
	NSString *date1 = @"06/21/2013";
	NSDate *expectedDate1 = [dateFormatter dateFromString:date1];
	
	NSString *title2 = @"title 2";
	NSString *date2 = @"02/16/2012";
	NSDate *expectedDate2 = [dateFormatter dateFromString:date2];
	
	NSMutableDictionary *postDictionary = [NSMutableDictionary dictionary];
	[postDictionary setObject:title1 forKey:@"title"];
	[postDictionary setObject:date1 forKey:@"postedDate"];
	
	NSMutableDictionary *postDictionary2 = [NSMutableDictionary dictionary];
	[postDictionary2 setObject:title2 forKey:@"title"];
	[postDictionary2 setObject:date2 forKey:@"postedDate"];
	
	NSMutableDictionary *userDict = [NSMutableDictionary dictionary];
	[userDict setObject:@[postDictionary2, postDictionary] forKey:@"posts"];
	
	CDUser *user = [self.mapper objectFromSource:userDict toInstanceOfClass:[CDUser class]];
}

@end
