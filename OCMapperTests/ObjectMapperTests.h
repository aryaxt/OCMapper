//
//  ObjectMapperTests.h
//  ObjectMapperTests
//
//  Created by Aryan Gh on 4/14/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ObjectMapper.h"
#import "InCodeMappintProvider.h"

@interface ObjectMapperTests : SenTestCase

@property (nonatomic, strong) ObjectMapper *mapper;
@property (nonatomic, strong) InCodeMappintProvider *mappingProvider;

@end
