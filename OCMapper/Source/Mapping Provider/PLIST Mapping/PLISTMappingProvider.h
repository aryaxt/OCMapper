//
//  PLISTMappingProvider.h
//  OCMapper
//
//  Created by Aryan Gh on 4/23/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MappingProvider.h"
#import "ObjectMappingInfo.h"

@interface PLISTMappingProvider : NSObject <MappingProvider>

- (id)initWithFileName:(NSString *)fileName;

@end
