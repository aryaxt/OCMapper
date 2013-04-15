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

#pragma mark - Helpers -

- (NSDictionary *)userDictionary
{
	/*NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];
	[addressDictionary setObject:city forKey:@"city"];
	[addressDictionary setObject:country forKey:@"country"];
	
	NSMutableDictionary *authorAddressDictionary = [NSMutableDictionary dictionary];
	[addressDictionary setObject:authorCity forKey:@"city"];
	[addressDictionary setObject:authorCountry forKey:@"country"];
	
	NSMutableDictionary *authorDictionary = [NSMutableDictionary dictionary];
	[authorDictionary setObject:authorFirstName forKey:@"firstName"];
	[authorDictionary setObject:authirLastName forKey:@"lastName"];
	[authorDictionary setObject:[NSNumber numberWithInt:authorAge] forKey:@"age"];
	[authorDictionary setObject:authorAddressDictionary forKey:@"address"];
	
	NSMutableDictionary *commentDictionary = [NSMutableDictionary dictionary];
	[commentDictionary setObject:postTitle forKey:@"title"];
	[commentDictionary setObject:postBody forKey:@"body"];
	[commentDictionary setObject:authorDictionary forKey:@"author"];
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:firstName forKey:@"firstName"];
	[userDictionary setObject:lastName forKey:@"lastName"];
	[userDictionary setObject:[NSNumber numberWithInt:age] forKey:@"age"];
	[userDictionary setObject:addressDictionary forKey:@"address"];
	[userDictionary setObject:@[commentDictionary, commentDictionary, commentDictionary] forKey:@"comments"];*/
	return nil;
}

- (NSDictionary *)dictionaryFromJsonString:(NSString *)jsonString
{
	return [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
										   options:NSJSONReadingMutableContainers
											 error:nil];
}

@end
