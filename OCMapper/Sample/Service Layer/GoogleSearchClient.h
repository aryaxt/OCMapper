//
//  GoogleSearchClient.h
//  OCMapper
//
//  Created by Aryan Gh on 8/27/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceClient.h"
#import "GoogleSearchResponse.h"

@interface GoogleSearchClient : NSObject

- (void)searchWithKeyword:(NSString *)keyword andCompletion:(void (^)(GoogleSearchResponse *googleSearchResponse, NSError *error))completion;

@end
