//
//  ObjectMapperTests.m
//  ObjectMapperTests
//
//  Created by Aryan Gh on 4/14/13.
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

#import "ObjectMapperTests.h"
#import "ObjectMapper.h"
#import "User.h"
#import "CDUser.h"
#import "Comment.h"
#import "SpecialUser.h"

@implementation ObjectMapperTests
@synthesize mapper;
@synthesize instanceProvider;
@synthesize mappingProvider;

#pragma mark - Setup & Teardown -

- (void)setUp
{
	[super setUp];
	
	self.mappingProvider = [[InCodeMappingProvider alloc] init];
	self.instanceProvider = [[ObjectInstanceProvider alloc] init];
	
	self.mapper = [[ObjectMapper alloc] init];
	self.mapper.mappingProvider = self.mappingProvider;
}

- (void)tearDown
{
	self.mapper = nil;
	self.mappingProvider =  nil;
	
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
	XCTAssertEqualObjects(user.firstName, firstName, @"firstName did not populate correctly");
	XCTAssertEqualObjects(user.age, age, @"age did not populate correctly");
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
	XCTAssertEqualObjects(user.address.city, city, @"city did not populate correctly");
	XCTAssertEqualObjects(user.address.country, country, @"country did not populate correctly");
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
	XCTAssertEqualObjects(user.address.city, city, @"city did not populate correctly");
	XCTAssertEqualObjects(user.address.country, country, @"country did not populate correctly");
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
	
	[self.mappingProvider mapFromDictionaryKey:ADDRESS_KEY toPropertyKey:@"address" withObjectType:[Address class] forClass:[User class]];
	[self.mappingProvider mapFromDictionaryKey:CITY_KEY toPropertyKey:@"city" forClass:[Address class]];
	[self.mappingProvider mapFromDictionaryKey:COUNTRY_KEY toPropertyKey:@"country" forClass:[Address class]];
	
	User *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[User class]];
	XCTAssertEqualObjects(user.address.city, city, @"city did not populate correctly");
	XCTAssertEqualObjects(user.address.country, country, @"country did not populate correctly");
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
	
	[self.mappingProvider mapFromDictionaryKey:SOME_FIRST_NAME_KEY toPropertyKey:@"firstName" forClass:[User class]];
	[self.mappingProvider mapFromDictionaryKey:SOME_AGE_KEY toPropertyKey:@"age" forClass:[User class]];
	
	User *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[User class]];
	XCTAssertEqualObjects(user.firstName, firstName, @"firstName did not populate correctly");
	XCTAssertEqualObjects(user.age, age, @"age did not populate correctly");
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
	XCTAssertTrue([user.dateOfBirth isEqual:expectedDate], @"date did not populate correctly");
}

- (void)testAutomaticDMappingWithArrayOnRootLevel
{
	NSMutableDictionary *user1Dictionary = [NSMutableDictionary dictionary];
	[user1Dictionary setObject:@"Aryan" forKey:@"firstName"];
	
	NSMutableDictionary *user2Dictionary = [NSMutableDictionary dictionary];
	[user2Dictionary setObject:@"Chuck" forKey:@"firstName"];
	
	NSArray *users = [self.mapper objectFromSource:@[user1Dictionary, user2Dictionary] toInstanceOfClass:[User class]];
	XCTAssertTrue(users.count == 2, @"Did not populate correct number of items");
	XCTAssertTrue([[[users objectAtIndex:0] firstName] isEqual:
				   [user1Dictionary objectForKey:@"firstName"]], @"Did not populate correct attributes");
	XCTAssertTrue([[[users objectAtIndex:1] firstName] isEqual:
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
	
	[self.mappingProvider setDateFormatter:dateOfBirthFormatter forPropertyKey:@"dateOfBirth" andClass:[User class]];
	[self.mappingProvider setDateFormatter:accountCreationFormatter forPropertyKey:@"accountCreationDate" andClass:[User class]];
	
	User *user = [self.mapper objectFromSource:userDict toInstanceOfClass:[User class]];
	XCTAssertNotNil(user.accountCreationDate, @"Did nor populate date");
	XCTAssertNotNil(user.dateOfBirth, @"Did nor populate date");
	XCTAssertTrue([user.accountCreationDate isEqualToDate:user.dateOfBirth], @"Did not populate dates correctly");
}

- (void)testAutoMappingShouldNotBeCaseSensitive
{
	NSString *firstName = @"Aryan";
	NSNumber *age = @26;
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:firstName forKey:@"FirstNAmE"];
	[userDictionary setObject:age forKey:@"aGe"];
	
	User *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[User class]];
	XCTAssertEqualObjects(user.firstName, firstName, @"firstName did not populate correctly");
	XCTAssertEqualObjects(user.age, age, @"age did not populate correctly");
}

- (void)testPerformance
{
	NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];
	[addressDictionary setObject:@"SAN DIEGO" forKey:@"city"];
	[addressDictionary setObject:@"US" forKey:@"country"];
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:@"Aryan" forKey:@"firstName"];
	[userDictionary setObject:@"Ghassemi" forKey:@"lastName"];
	[userDictionary setObject:@26 forKey:@"age"];
	[userDictionary setObject:@"01-21/2005" forKey:@"dateOfBirth"];
	[userDictionary setObject:addressDictionary forKey:@"address"];
	
	[self measureBlock:^{
		NSMutableArray *usersDictionary = [NSMutableArray array];
		
		for (int i=0 ; i<50 ; i++) {
			[usersDictionary addObject:userDictionary];
		}
		
		[self.mapper objectFromSource:usersDictionary toInstanceOfClass:[User class]];
	}];
}

- (void)testDictionaryFromFlatObject
{
	User *user = [[User alloc] init];
	user.firstName = @"Aryan";
	user.lastName = @"Ghassmei";
	user.age = @26;
	user.dateOfBirth = [NSDate date];
	
	NSDictionary *dictionary = [self.mapper dictionaryFromObject:user];
	
	XCTAssertTrue([[dictionary objectForKey:@"firstName"] isEqual:user.firstName], @"Did not populate dictionary correctly");
	XCTAssertTrue([[dictionary objectForKey:@"lastName"] isEqual:user.lastName], @"Did not populate dictionary correctly");
	XCTAssertTrue([[dictionary objectForKey:@"age"] isEqual:user.age], @"Did not populate dictionary correctly");
}

- (void)testDictionaryFromComplexObject
{
	Address *address = [[Address alloc] init];
	address.city = @"San Diego";
	address.country = @"US";
	
	User *user = [[User alloc] init];
	user.address = address;
	
	NSDictionary *dictionary = [self.mapper dictionaryFromObject:user];
	NSDictionary *addressDictionary = [dictionary objectForKey:@"address"];
	
	XCTAssertTrue([[addressDictionary objectForKey:@"city"] isEqual:user.address.city], @"Did not populate dictionary correctly");
	XCTAssertTrue([[addressDictionary objectForKey:@"country"] isEqual:user.address.country], @"Did not populate dictionary correctly");
}

- (void)testDictionaryFromObjectWithNestedArray
{
	Comment *comment = [[Comment alloc] init];
	comment.body = @"COMMENT BODY";
	
	User *user = [[User alloc] init];
	user.comments = [NSMutableArray array];
	[user.comments addObject:comment];
	[user.comments addObject:comment];
	
	NSDictionary *dictionary = [self.mapper dictionaryFromObject:user];
	NSArray *comments = [dictionary objectForKey:@"comments"];
	
	XCTAssertTrue(comments.count == 2, @"Did not populate dictionary correctly");
	XCTAssertTrue([[[comments objectAtIndex:0] objectForKey:@"body"] isEqual:comment.body], @"Did not populate dictionary correctly");
}

- (void)testDictionaryFromArrayOfObjects
{
	Comment *comment1 = [[Comment alloc] init];
	comment1.body = @"1";
	
	Comment *comment2 = [[Comment alloc] init];
	comment2.body = @"2";
	
	NSArray *comments = @[comment1, comment2];
	NSArray *arrayOfDictionary = [self.mapper dictionaryFromObject:comments];
	
	XCTAssertTrue(arrayOfDictionary.count == 2, @"Did not populate correct number of dictionaries in array");
	
	NSString *commentBody1 = [[arrayOfDictionary objectAtIndex:0] objectForKey:@"body"];
	NSString *commentBody2 = [[arrayOfDictionary objectAtIndex:1] objectForKey:@"body"];
	
	XCTAssertTrue([commentBody1 isEqual:@"1"], @"Did not popoukate dictionary correctly");
	XCTAssertTrue([commentBody2 isEqual:@"2"], @"Did not popoukate dictionary correctly");
}

- (void)testMappingshouldNotBeCaseSensitiveForPropertyNameWithCustomMapping
{
	NSString *firstNameProperty = @"FiRsTNaMe";
	NSString *firstNameKey = @"first_name";
	NSString *firstName = @"Aryan";
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:firstName forKey:firstNameKey];
	
	[self.mappingProvider mapFromDictionaryKey:firstNameKey toPropertyKey:firstNameProperty forClass:[User class]];
	
	User *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[User class]];
	XCTAssertEqualObjects(user.firstName, firstName, @"firstName did not populate correctly");
}

- (void)testMappingshouldNotBeCaseSensitiveForPropertyName
{
	NSString *firstName = @"Aryan";
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:firstName forKey:@"FirsTNAmE"];
	
	User *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[User class]];
	XCTAssertEqualObjects(user.firstName, firstName, @"firstName did not populate correctly");
}

- (void)testMappingshouldNotBeCaseSensitiveForDictionaryKeyValue
{
	NSString *firstNameKey = @"first_name";
	NSString *firstNameKeyDifferentCase = @"firsT_name";
	NSString *firstName = @"Aryan";
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:firstName forKey:firstNameKey];
	
	[self.mappingProvider mapFromDictionaryKey:firstNameKeyDifferentCase toPropertyKey:@"firstname" forClass:[User class]];
	
	User *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[User class]];
	XCTAssertEqualObjects(user.firstName, firstName, @"firstName did not populate correctly");
}

- (void)testFlatDataToComplexObjectConversion
{
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:@"Aryan" forKey:@"firstName"];
	[userDictionary setObject:@"San Diego" forKey:@"city"];
	[userDictionary setObject:@"USA" forKey:@"country"];
	
	[self.mappingProvider mapFromDictionaryKey:@"city" toPropertyKey:@"address.city" forClass:[User class]];
	[self.mappingProvider mapFromDictionaryKey:@"country" toPropertyKey:@"address.country" forClass:[User class]];
	self.mapper.normalizeDictionary = YES;
	
	User *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[User class]];
	XCTAssertTrue([[userDictionary objectForKey:@"firstName"] isEqual:user.firstName], @"Did not populate dictionary correctly");
	XCTAssertTrue([[userDictionary objectForKey:@"city"] isEqual:user.address.city], @"Did not populate dictionary correctly");
	XCTAssertTrue([[userDictionary objectForKey:@"country"] isEqual:user.address.country], @"Did not populate dictionary correctly");
}

- (void)testShouldMapPropertyInSuperClass
{
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:@"Aryan" forKey:@"firstName"];
	[userDictionary setObject:@"stealth" forKey:@"power"];
	
	NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];
	[addressDictionary setObject:@"San Diego" forKey:@"city"];
	[userDictionary setObject:addressDictionary forKey:@"address"];
	
	
	SpecialUser *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[SpecialUser class]];
	
	XCTAssertTrue([[userDictionary objectForKey:@"firstName"] isEqual:user.firstName], @"Did not populate dictionary correctly");
	XCTAssertTrue([[userDictionary objectForKey:@"power"] isEqual:user.power], @"Did not populate dictionary correctly");
	XCTAssertTrue([[[userDictionary objectForKey:@"address"] objectForKey:@"city"] isEqual:user.address.city], @"Did not populate dictionary correctly");
}

- (void)testShouldTransformDataCorrectly {
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:@"Aryan" forKey:@"firstName"];
	[userDictionary setObject:@"San Diego" forKey:@"address"];
	
	Address *address = [[Address alloc] init];
	
	[self.mappingProvider mapFromDictionaryKey:@"address" toPropertyKey:@"address" forClass:[User class] withTransformer:^id(id currentNode, id parentNode) {
		
		address.city = currentNode;
		return address;
	}];
	
	User *user = [self.mapper objectFromSource:userDictionary toInstanceOfClass:[User class]];
	XCTAssertTrue(user.address == address);
	XCTAssertTrue([user.address.city isEqualToString:@"San Diego"]);
}

- (void)testShouldPopulateDictionaryWithPropertyInSuperClass
{
	SpecialUser *user = [[SpecialUser alloc] init];
	user.power = @"stealth";
	user.firstName = @"Aryan";
	
	NSDictionary *dictionary = [self.mapper dictionaryFromObject:user];
	XCTAssertTrue([user.firstName isEqual:[dictionary objectForKey:@"firstName"]], @"Did Not populate dictionary properly");
	XCTAssertTrue([user.power isEqual:[dictionary objectForKey:@"power"]], @"Did Not populate dictionary properly");
}

- (void)testInverseMappingShouldMapKeysWithCorrectName
{
	User *user = [[User alloc] init];
	user.firstName = @"Aryan";
	user.address = [[Address alloc] init];
	user.address.city = @"SF";
	
	[self.mappingProvider mapFromPropertyKey:@"firstName" toDictionaryKey:@"fName" forClass:[User class]];
	[self.mappingProvider mapFromPropertyKey:@"address" toDictionaryKey:@"location" forClass:[User class]];
	[self.mappingProvider mapFromPropertyKey:@"city" toDictionaryKey:@"ct" forClass:[Address class]];
	[self.mappingProvider mapFromPropertyKey:@"dateOfBirth" toDictionaryKey:@"dob" forClass:[User class] withTransformer:^id(id currentNode, id parentNode) {
		
		return @"2014";
	}];
	
	NSDictionary *dictionary = [self.mapper dictionaryFromObject:user];
	XCTAssertTrue([dictionary[@"fName"] isEqualToString:user.firstName]);
	XCTAssertTrue([dictionary[@"dob"] isEqualToString:@"2014"]);
	XCTAssertTrue([[dictionary[@"location"] objectForKey:@"ct"] isEqualToString:user.address.city]);
}

- (void)testShouldAutomaticallyGenerateInverseMapping
{
	[self.mappingProvider mapFromDictionaryKey:@"dateOfBirth" toPropertyKey:@"dob" forClass:[User class]];
	ObjectMappingInfo *info = [self.mappingProvider mappingInfoForClass:[User class] andPropertyKey:@"dob"];
	
	XCTAssertTrue([info.dictionaryKey isEqualToString:@"dateOfBirth"]);
}

- (void)testShouldNotAutomaticallyGenerateInverseMapping
{
	self.mappingProvider.automaticallyGenerateInverseMapping = NO;
	[self.mappingProvider mapFromDictionaryKey:@"dateOfBirth" toPropertyKey:@"dob" forClass:[User class]];
	ObjectMappingInfo *info = [self.mappingProvider mappingInfoForClass:[User class] andPropertyKey:@"dob"];
	
	XCTAssertNil(info);
}

- (void)testObjectInstanceProviderShouldReturnTrueForNSObjectSubclasses
{
	XCTAssertTrue([self.instanceProvider canHandleClass:User.class]);
}

- (void)testObjectInstanceProviderShouldReturnFalseForNSManagedObjectSubclasses
{
	XCTAssertFalse([self.instanceProvider canHandleClass:CDUser.class]);
}

@end
