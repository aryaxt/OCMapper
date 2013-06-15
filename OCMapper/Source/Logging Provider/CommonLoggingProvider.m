//
//  CommonLoggingProvider.m
//  OCMapper
//
//  Created by Aryan Gh on 6/10/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "CommonLoggingProvider.h"

@interface CommonLoggingProvider()
@property (nonatomic, assign) LogLevel logLevel;
@end

@implementation CommonLoggingProvider
@synthesize logLevel;

- (id)initWithLogLevel:(LogLevel)aLogLevel
{
	if (self = [super init])
	{
		self.logLevel = aLogLevel;
	}
	
	return self;
}

- (void)log:(NSString *)string withLevel:(LogLevel)level
{
	if (level >= self.logLevel)
		NSLog(@"%@", string);
}

@end
