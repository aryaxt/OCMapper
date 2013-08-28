//
//  OCMapperConfig.m
//  OCMapper
//
//  Created by Aryan Gh on 8/27/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "OCMapperConfig.h"
#import "OCMapper.h"
#import "GoogleSearchResult.h"
#import "GoogleSearchResponseData.h"
#import "GoogleSearchResponse.h"

@implementation OCMapperConfig

// We call this from appDelegate

+ (void)configure
{
	ObjectInstanceProvider *instanceProvider = [[ObjectInstanceProvider alloc] init];
	InCodeMappingProvider *inCodeMappingProvider = [[InCodeMappingProvider alloc] init];
	CommonLoggingProvider *commonLoggingProvider = [[CommonLoggingProvider alloc] initWithLogLevel:LogLevelInfo];
	
	[[ObjectMapper sharedInstance] setInstanceProvider:instanceProvider];
	[[ObjectMapper sharedInstance] setMappingProvider:inCodeMappingProvider];
	[[ObjectMapper sharedInstance] setLoggingProvider:commonLoggingProvider];
	
	/******************* Any custom mapping would go here **********************/
	
	// Map from key 'results' to property 'results' of type 'GoogleSearchResult' which is a property of 'GoogleSearchResponseData' class
	// If the class was named 'Result' it would be mapped automatically, and there would be no need to write any code
	[inCodeMappingProvider mapFromDictionaryKey:@"results"
								  toPropertyKey:@"results"
								 withObjectType:[GoogleSearchResult class]
									   forClass:[GoogleSearchResponseData class]];
	
	// Map from key 'responseData' to property 'responseData' of type 'GoogleSearchResponseData' which is a property of 'GoogleSearchResponse' class
	// If the class was named 'ResponseData' it would be mapped automatically, and there would be no need to write any code
	[inCodeMappingProvider mapFromDictionaryKey:@"responseData"
								  toPropertyKey:@"responseData"
								 withObjectType:[GoogleSearchResponseData class]
									   forClass:[GoogleSearchResponse class]];
}

@end
