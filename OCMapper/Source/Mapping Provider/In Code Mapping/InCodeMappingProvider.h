//
//  InCodeMappintProvider.h
//  OCMapper
//
//  Created by Aryan Gh on 4/20/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MappingProvider.h"
#import "ObjectMappingInfo.h"

@interface InCodeMappingProvider : NSObject <MappingProvider>

- (void)mapFromDictionaryKey:(NSString *)dictionaryKey toPropertyKey:(NSString *)propertyKey withObjectType:(Class)objectType forClass:(Class)class;
- (void)mapFromDictionaryKey:(NSString *)dictionaryKey toPropertyKey:(NSString *)propertyKey forClass:(Class)class;
- (void)setDateFormatter:(NSDateFormatter *)dateFormatter forProperty:(NSString *)property andClass:(Class)class;

@end
