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

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

AppDelegate *sharedDelegate;

@interface AppDelegate ()

-(void)didLogIn:(NSNotification *)note;
-(void)addv7Appearance:(UIApplication *)application;

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
    
    [self addv7Appearance:application];
    
    return YES;
}

-(void)addv7Appearance:(UIApplication *)application
{
    UIColor *officialBlue = UIColorFromRGB(0x00274c);
    UIColor *officialMaize = UIColorFromRGB(0xffcb05);
    
    UIColor *barColor = [UIColor colorWithRed:0 green:.15 blue:.30 alpha:0.4];
    UIColor *tintColor = [UIColor colorWithRed:1.0 green:1.0 blue:0 alpha:1.0];
    UIColor *controlColor = [UIColor colorWithRed:0 green:0 blue:.4 alpha:1.0];
    
    
    tintColor = officialMaize;
    controlColor = officialBlue;
    
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UITabBar appearance] setBarStyle:UIBarStyleBlack];
    
    [[UINavigationBar appearance] setBarTintColor:barColor];
    [[UITabBar appearance] setBarTintColor:barColor];
    
    // We need to wait a tick for this, because application.keyWindow is nil right now.
    dispatch_async(dispatch_get_main_queue(), ^{
        application.keyWindow.tintColor = tintColor;
    });
    
    [[UITextField appearance] setTintColor:controlColor];
    [[UIStepper appearance] setTintColor:controlColor];
    [[UITableViewCell appearance] setTintColor:controlColor];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:@{ UITextAttributeTextColor : controlColor} forState:UIControlStateNormal];
    
    [[UISwitch appearance] setOnTintColor:controlColor];
    
    // Not entirely sure on this. I think whiting out the search bar completely does look pretty cool.
    [[UISearchBar appearance] setBarTintColor:[UIColor whiteColor]];
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
