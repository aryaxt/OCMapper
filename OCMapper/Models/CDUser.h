//
//  CDUser.h
//  OCMapper
//
//  Created by Aryan Gh on 4/16/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDAddress.h"

@interface CDUser : NSManagedObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSDate *dateOfBirth;
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, strong) CDAddress *address;
@property (nonatomic, strong) NSSet *posts;

@end
