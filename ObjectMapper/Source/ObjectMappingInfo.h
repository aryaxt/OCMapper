//
//  ObjectMapperInfo.h
//  iFollow
//
//  Created by Aryan Gh on 4/14/13.
//  Copyright (c) 2013 Aryan Gh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectMappingInfo : NSObject

@property (nonatomic, strong) NSString *dictionaryKey;
@property (nonatomic, strong) NSString *propertyKey;
@property (nonatomic, assign) Class objectType;

- (id)initWithDictionaryKey:(NSString *)aDictionaryKey propertyKey:(NSString *)aPropertyKey andObjectType:(Class)anObjectType;

@end
