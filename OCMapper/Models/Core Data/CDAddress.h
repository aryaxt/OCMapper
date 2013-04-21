//
//  CDAddress.h
//  OCMapper
//
//  Created by Aryan Gh on 4/16/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface CDAddress : NSManagedObject

@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *country;

@end
