//
//  ManagedObjectMapperTest.h
//  OCMapper
//
//  Created by Aryan Gh on 4/16/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ObjectMapper.h"
#import "ManagedObjectInstanceProvider.h"
#import "InCodeMappintProvider.h"

@interface ManagedObjectMapperTest : SenTestCase

@property (nonatomic, strong) ObjectMapper *mapper;
@property (nonatomic, strong) InCodeMappintProvider *mappingProvider;

@end
