//
//  AppDelegate.m
//  BluePrinter
//
//  Created by David Paul Quesada on 1/14/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "AppDelegate.h"
#import "MPrintLocalService.h"
#import "MPrintCosignManager.h"
#import "Location.h"
#import "Service.h"
#import "PrintJob.h"

AppDelegate *sharedDelegate;

@interface AppDelegate ()

-(void)didLogIn:(NSNotification *)note;

@end

@implementation AppDelegate

+(instancetype)sharedDelegate
{
    return sharedDelegate;
}

-(UIStoryboard *)mainStoryboard
{
    static UIStoryboard *board = nil;
    if (!board)
        board = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    return board;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    sharedDelegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogIn:) name:MPrintUserDidLogInNotification object:nil];
    return YES;
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

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *path = [url path];
    [[Service localService] importFileAtLocalPath:path];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    return YES;
}

-(void)didLogIn:(NSNotification *)note
{
    NSLog(@"Refreshing Stuff");
    [Location refreshLocations:nil];
    [Location refreshRecentLocations:nil];
    [Service refreshServices:nil];
    [PrintJob refreshUserJobs:nil];
}

@end
