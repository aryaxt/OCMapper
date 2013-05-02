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
#import "InCodeMappingProvider.h"

@interface ManagedObjectMapperTest : SenTestCase

@property (nonatomic, strong) ObjectMapper *mapper;
@property (nonatomic, strong) InCodeMappingProvider *mappingProvider;
@property (nonatomic, strong) ManagedObjectInstanceProvider *instanceProvider;

@end
