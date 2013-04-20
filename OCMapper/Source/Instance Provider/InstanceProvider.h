//
//  InstanceProvider.h
//  OCMapper
//
//  Created by Aryan Gh on 4/20/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol InstanceProvider <NSObject>

- (id)emptyInstanceFromClass:(Class)class;
- (id)emptyInstanceOfCollectionObject;
- (NSString *)propertyNameForObject:(NSObject *)object byCaseInsensitivePropertyName:(NSString *)caseInsensitivePropertyName;

@end
