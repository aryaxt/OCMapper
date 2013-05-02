//
//  XMLMappingProvider.h
//  OCMapper
//
//  Created by Aryan Gh on 4/20/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MappingProvider.h"

@interface XMLMappingProvider : NSObject <MappingProvider>

- (id)initWithXmlFile:(NSString *)fileName;

@end
