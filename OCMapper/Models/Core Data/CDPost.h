//
//  CDPost.h
//  OCMapper
//
//  Created by Aryan Gh on 4/16/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "CDUser.h"

@interface CDPost : NSManagedObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *postedDate;

@end
