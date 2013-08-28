//
//  ServiceClient.m
//  OCMapper
//
//  Created by Aryan Gh on 8/27/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "ServiceClient.h"
#import "AFNetworking.h"
#import "OCMapper.h"

@implementation ServiceClient

- (void)fetchDataWithUrl:(NSString *)urlString returnType:(Class)returnType andCompletion:(void (^)(id result, NSError *error))completion
{
	NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		
		// If result type exists convert it to model object, otherwise return NSDictionary
		completion((returnType) ? [returnType objectFromDictionary:JSON] : JSON, nil);
		
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
		completion(nil, error);
	}];
	[operation start];
}

@end
