//
//  ObjectMapperTests.m
//  ObjectMapperTests
//
//  Created by Aryan Gh on 4/14/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "ObjectMapperTests.h"
#import "ObjectMapper.h"
#import "User.h"

@implementation ObjectMapperTests
@synthesize mapper;

#pragma mark - Setup & Teardown -

- (void)setUp
{
    [super setUp];
	
	self.mapper = [[ObjectMapper alloc] init];
}

- (void)tearDown
{
	self.mapper = nil;
	
    [super tearDown];
}

#pragma mark - Tests -

- (void)testOneToOneSimpleMapping
{
	NSString *firstName = @"Aryan";
	NSNumber *age = @26;
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:firstName forKey:@"firstName"];
	[userDictionary setObject:age forKey:@"age"];
	
	User *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[User class]];
	STAssertEqualObjects(user.firstName, firstName, @"firstName did not populate correctly");
	STAssertEqualObjects(user.age, age, @"age did not populate correctly");
}

- (void)testOneToOneSimpleNestedMappingWithSmallCaseNestedKey
{
	NSString *city = @"A city Name";
	NSString *country = @"A country goes here";
	
	NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];
	[addressDictionary setObject:city forKey:@"city"];
	[addressDictionary setObject:country forKey:@"country"];
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:addressDictionary forKey:@"address"];
	
	User *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[User class]];
	STAssertEqualObjects(user.address.city, city, @"city did not populate correctly");
	STAssertEqualObjects(user.address.country, country, @"country did not populate correctly");
}

- (void)testOneToOneSimpleNestedMapping
{
	NSString *city = @"A city Name";
	NSString *country = @"A country goes here";
	
	NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];
	[addressDictionary setObject:city forKey:@"city"];
	[addressDictionary setObject:country forKey:@"country"];
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:addressDictionary forKey:@"address"];
	
	User *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[User class]];
	STAssertEqualObjects(user.address.city, city, @"city did not populate correctly");
	STAssertEqualObjects(user.address.country, country, @"country did not populate correctly");
}

- (void)testOneToOneCustomNestedMapping
{
	NSString *city = @"A city Name";
	NSString *country = @"A country goes here";
	NSString *CITY_KEY = @"SOME_CITY_KEY";
	NSString *COUNTRY_KEY = @"SOME_COUNTRY_KEY";
	NSString *ADDRESS_KEY = @"SOME_ADDRESS_KEY";
	
	NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];
	[addressDictionary setObject:city forKey:CITY_KEY];
	[addressDictionary setObject:country forKey:COUNTRY_KEY];
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:addressDictionary forKey:ADDRESS_KEY];
	
	[self.mapper mapFromDictionaryKey:ADDRESS_KEY toPropertyKey:@"address" withObjectType:[Address class] forClass:[User class]];
	[self.mapper mapFromDictionaryKey:CITY_KEY toPropertyKey:@"city" forClass:[Address class]];
	[self.mapper mapFromDictionaryKey:COUNTRY_KEY toPropertyKey:@"country" forClass:[Address class]];
	
	User *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[User class]];
	STAssertEqualObjects(user.address.city, city, @"city did not populate correctly");
	STAssertEqualObjects(user.address.country, country, @"country did not populate correctly");
}

- (void)testOneToOneCustomMapping
{
	NSString *firstName = @"Aryan";
	NSNumber *age = @26;
	
	NSString *SOME_FIRST_NAME_KEY = @"SOME_FIRST_NAME";
	NSString *SOME_AGE_KEY = @"A_RANDOM_AGE_FIELD";
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:firstName forKey:SOME_FIRST_NAME_KEY];
	[userDictionary setObject:age forKey:SOME_AGE_KEY];
	
	[self.mapper mapFromDictionaryKey:SOME_FIRST_NAME_KEY toPropertyKey:@"firstName" forClass:[User class]];
	[self.mapper mapFromDictionaryKey:SOME_AGE_KEY toPropertyKey:@"age" forClass:[User class]];
	
	User *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[User class]];
	STAssertEqualObjects(user.firstName, firstName, @"firstName did not populate correctly");
	STAssertEqualObjects(user.age, age, @"age did not populate correctly");
}

- (void)testAutomaticDateConversion
{
	NSString *dateString = @"06/21/2013";
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MM/dd/yyyy"];
	NSDate *expectedDate = [dateFormatter dateFromString:dateString];
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:dateString forKey:@"dateOfBirth"];
	
	User *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[User class]];
	STAssertTrue([user.dateOfBirth isEqual:expectedDate], @"date did not populate correctly");
}

- (void)testAutomaticDMappingWithArrayOnRootLevel
{
	NSMutableDictionary *user1Dictionary = [NSMutableDictionary dictionary];
	[user1Dictionary setObject:@"Aryan" forKey:@"firstName"];
	
	NSMutableDictionary *user2Dictionary = [NSMutableDictionary dictionary];
	[user2Dictionary setObject:@"Chuck" forKey:@"firstName"];
	
	NSArray *users = [self.mapper objectFromSource:@[user1Dictionary, user2Dictionary] toInstanceOfClass:[User class]];
	STAssertTrue(users.count == 2, @"Did not populate correct number of items");
	STAssertTrue([[[users objectAtIndex:0] firstName] isEqual:
				  [user1Dictionary objectForKey:@"firstName"]], @"Did not populate correct attributes");
	STAssertTrue([[[users objectAtIndex:1] firstName] isEqual:
				  [user2Dictionary objectForKey:@"firstName"]], @"Did not populate correct attributes");
}

- (void)testCustomDateConversion
{
	NSString *dateOfBirthString = @"01-21/2005";
	NSDateFormatter *dateOfBirthFormatter = [[NSDateFormatter alloc] init];
	[dateOfBirthFormatter setDateFormat:@"MM-dd/yyyy"];
	
	NSString *accountCreationDateString = @"01(2005(21";
	NSDateFormatter *accountCreationFormatter = [[NSDateFormatter alloc] init];
	[accountCreationFormatter setDateFormat:@"MM(yyyy(dd"];
	
	NSMutableDictionary *userDict = [NSMutableDictionary dictionary];
	[userDict setObject:dateOfBirthString forKey:@"dateOfBirth"];
	[userDict setObject:accountCreationDateString forKey:@"accountCreationDate"];
	
	[self.mapper setDateFormatter:dateOfBirthFormatter forProperty:@"dateOfBirth" andClass:[User class]];
	[self.mapper setDateFormatter:accountCreationFormatter forProperty:@"accountCreationDate" andClass:[User class]];
	
	User *user = [self.mapper objectFromSource:userDict toInstanceOfClass:[User class]];
	STAssertNotNil(user.accountCreationDate, @"Did nor populate date");
	STAssertNotNil(user.dateOfBirth, @"Did nor populate date");
	STAssertTrue([user.accountCreationDate isEqualToDate:user.dateOfBirth], @"Did not populate dates correctly");
}

@end
