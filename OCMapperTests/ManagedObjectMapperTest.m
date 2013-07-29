//
//  ManagedObjectMapperTest.m
//  OCMapper
//
//  Created by Aryan Gh on 4/16/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//
// https://github.com/aryaxt/OCMapper
//
// Permission to use, copy, modify and distribute this software and its documentation
// is hereby granted, provided that both the copyright notice and this permission
// notice appear in all copies of the software, derivative works or modified versions,
// and any portions thereof, and that both notices appear in supporting documentation,
// and that credit is given to Aryan Ghassemi in all documents and publicity
// pertaining to direct or indirect use of this code or its derivatives.
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
#import "CoreDataManager.h"
#import	"CDUser.h"
#import "CDAddress.h"
#import "CDPost.h"

@implementation ManagedObjectMapperTest
@synthesize mapper;
@synthesize mappingProvider;
@synthesize instanceProvider;

#pragma mark - Setup & Teardown -

- (void)setUp
{
    [super setUp];
	
	CoreDataManager *coreDataManager = [[CoreDataManager alloc] init];
	self.instanceProvider = [[ManagedObjectInstanceProvider alloc]
													   initWithManagedObjectContext:coreDataManager.managedObjectContext];
	
	self.mappingProvider = [[InCodeMappingProvider alloc] init];
	
	self.mapper = [[ObjectMapper alloc] init];
	self.mapper.mappingProvider = self.mappingProvider;
	self.mapper.instanceProvider = self.instanceProvider;
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
	//NSDate *expectedDate1 = [dateFormatter dateFromString:date1];
	
	NSString *title2 = @"title 2";
	NSString *date2 = @"02/16/2012";
	//NSDate *expectedDate2 = [dateFormatter dateFromString:date2];
	
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

@end
