//
//  LoggingProvider.h
//  OCMapper
//
//  Created by Aryan Gh on 6/10/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef  enum{
	LogLevelInfo = 1,
	LogLevelWarning = 2,
	LogLevelError = 3
}LogLevel;

@protocol LoggingProvider <NSObject>

- (void)log:(NSString *)string withLevel:(LogLevel)logLevel;
- (id)initWithLogLevel:(LogLevel)logLevel;

@end
