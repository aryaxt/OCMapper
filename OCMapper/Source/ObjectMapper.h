//
//  ObjectMapper.h
//  OCMapper
//
//  Created by Aryan Gh on 4/14/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "ObjectMappingInfo.h"
#import "InstanceProvider.h"
#import "MappingProvider.h"
#import "LoggingProvider.h"

@interface ObjectMapper : NSObject

@property (nonatomic, strong) NSDateFormatter *defaultDateFormatter;
@property (nonatomic, strong) id <InstanceProvider> instanceProvider;
@property (nonatomic, strong) id <MappingProvider> mappingProvider;
@property (nonatomic, strong) id <LoggingProvider> loggingProvider;

+ (ObjectMapper *)sharedInstance;
- (id)objectFromSource:(id)source toInstanceOfClass:(Class)class;
- (NSDictionary *)dictionaryFromObject:(NSObject *)object;

@end
