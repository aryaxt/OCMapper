//
//  AppDelegate.m
//  ObjectMapper
//
//  Created by Aryan Gh on 4/14/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "AppDelegate.h"
#import "User.h"
#import "Comment.h"
#import "OCMapper.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self testObjectMapper];
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)testObjectMapper
{
	NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionary];
	[addressDictionary setObject:@"San Diego" forKey:@"city"];
	[addressDictionary setObject:@"US" forKey:@"country"];
	
	NSMutableDictionary *authorDictionary = [NSMutableDictionary dictionary];
	[authorDictionary setObject:@"Bijan" forKey:@"firstName"];
	[authorDictionary setObject:@"Ghassemi" forKey:@"lastName"];
	[authorDictionary setObject:@20 forKey:@"age"];
	[authorDictionary setObject:addressDictionary forKey:@"address"];
	
	NSMutableDictionary *commentDictionary = [NSMutableDictionary dictionary];
	[commentDictionary setObject:@"This is an awesome title" forKey:@"title"];
	[commentDictionary setObject:@"this is the body of my crazy crazy post" forKey:@"body"];
	[commentDictionary setObject:authorDictionary forKey:@"author"];
	
	NSMutableDictionary *userDictionary = [NSMutableDictionary dictionary];
	[userDictionary setObject:@"Aryan" forKey:@"firstName"];
	[userDictionary setObject:@"Ghassemi" forKey:@"lastName"];
	[userDictionary setObject:@26 forKey:@"age"];
	[userDictionary setObject:@"2013-05-01" forKey:@"dateOfBirth"];
	[userDictionary setObject:addressDictionary forKey:@"address"];
	[userDictionary setObject:@[commentDictionary, commentDictionary, commentDictionary] forKey:@"comments"];
	[userDictionary setObject:@[@"hello", @"byy", @"go", @"come back"] forKey:@"randomKeywords"];
	
	[[ObjectMapper sharedInstance] mapFromDictionaryKey:@"" toPropertyKey:@"" forClass:[NSString class]];
	[[ObjectMapper sharedInstance] mapFromDictionaryKey:@"author" toPropertyKey:@"author" withObjectType:[User class] forClass:[Comment class]];
	
	id result = [[ObjectMapper sharedInstance] objectFromSource:@[userDictionary, userDictionary, userDictionary] toInstanceOfClass:[User class]];
	NSLog(@"%@", result);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
