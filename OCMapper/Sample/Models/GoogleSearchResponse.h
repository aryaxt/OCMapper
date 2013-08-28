//
//  GoogleSearchResponse.h
//  OCMapper
//
//  Created by Aryan Gh on 8/27/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoogleSearchResponseData.h"

@interface GoogleSearchResponse : NSObject

@property (nonatomic, strong) NSString *responseDetails;
@property (nonatomic, strong) NSNumber *responseStatus;
@property (nonatomic, strong) GoogleSearchResponseData *responseData;

@end
