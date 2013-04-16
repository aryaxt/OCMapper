//
//  User.h
//  OCMapper
//
//  Created by Aryan Gh on 4/14/13.
//  Copyright (c) 2013 Aryan Gh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Address.h"

@interface User : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSDate *dateOfBirth;
@property (nonatomic, strong) NSDate *accountCreationDate;
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, strong) Address *address;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) NSMutableArray *randomKeywords;

@end
