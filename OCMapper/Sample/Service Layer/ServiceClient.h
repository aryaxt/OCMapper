//
//  ServiceClient.h
//  OCMapper
//
//  Created by Aryan Gh on 8/27/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceClient : NSObject

- (void)fetchDataWithUrl:(NSString *)urlString returnType:(Class)returnType andCompletion:(void (^)(id result, NSError *error))completion;

@end
