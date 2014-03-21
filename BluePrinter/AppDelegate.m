//
//  AppDelegate.m
//  BluePrinter
//
//  Created by David Paul Quesada on 1/14/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MPrintLocalService.h"
#import "MPrintCosignManager.h"
#import "Location.h"
#import "Service.h"
#import "PrintJob.h"
#import "PrintRequest.h"
#import "PrintJobTableViewController.h"
#import "Account.h"
#import "NotificationManager.h"
#import "UserDefaults.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

AppDelegate *sharedDelegate;

@interface AppDelegate ()
{
    BOOL _hasRegisteredNotifications;
    __weak UIAlertView *_connectionFailedAlertView;
}

-(void)didLogIn:(NSNotification *)note;
-(void)didImportDocument:(NSNotification *)note;
-(void)requestDidFail:(NSNotification *)note;
-(void)connectionDidFail:(NSNotification *)note;
-(void)addv7Appearance:(UIApplication *)application;

-(void)showJobsTabOfApplication:(UIApplication *)application;

-(UIViewController *)targetViewController;
-(void)registerForNotifications;

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

-(void)showJobsTabOfApplication:(UIApplication *)application
{
    UITabBarController *cont = (id)[application.windows.firstObject rootViewController];
    
    if ([cont isKindOfClass:[UITabBarController class]])
        cont.selectedIndex = 1;
    
    // Dismiss any notifications from the notification center if a user
    // tapped one to come here.
    [application cancelAllLocalNotifications];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    sharedDelegate = self;
    [self registerForNotifications];
    
    [self addv7Appearance:application];
    
    // If we're launching the app because the user tapped a notification about a job state,
    // let's show them the jobs view controller.
    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey])
        [self showJobsTabOfApplication:application];
    
    return YES;
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // We only want to do this if the application is inactive, otherwise the app will forcibly
    // move to the jobs tab after printing a document (which for now is not what I want, but may change).
    if (application.applicationState == UIApplicationStateInactive)
        [self showJobsTabOfApplication:application];
}

-(void)registerForNotifications
{
    if (_hasRegisteredNotifications)
        return;
    _hasRegisteredNotifications = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogIn:) name:MPrintUserDidLogInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didImportDocument:) name:MPrintDidImportFileNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestDidFail:) name:MPrintRequestApplicationDidFailNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionDidFail:) name:MPrintRequestConnectionDidFailNotification object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        
        // Apparently after we added the launch images, we can't use UIApp.keyWindow anymore.
        // That appears to fail when the user has airplane mode on. I guess the keyWindow returns
        // something related to a UIAlertView, which appears at launch because the network
        // calls to log in fail immediately. For some reason though, that window doesn't show up
        // in application.windows, so we can just pull the window from there.
        UIWindow *window = [application.windows firstObject];
        window.tintColor = tintColor;
    });
    
    [[UITextField appearance] setTintColor:controlColor];
    [[UIStepper appearance] setTintColor:controlColor];
    [[UITableViewCell appearance] setTintColor:controlColor];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:@{ NSForegroundColorAttributeName : controlColor} forState:UIControlStateNormal];
    
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
    [[NotificationManager defaultNotificationManager] applicationWillEnterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NotificationManager defaultNotificationManager] applicationWillEnterForeground];
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
    [self registerForNotifications];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *path = [url path];
        [[Service localService] importFileAtLocalPath:path];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    });

    return YES;
}

-(void)didLogIn:(NSNotification *)note
{
    NSDebugLog(@"Refreshing Stuff");
    [Location refreshLocations:nil];
    [Location refreshRecentLocations:nil];
    [Service refreshServices:nil];
    [PrintJob refreshUserJobs:nil];
}

-(void)didImportDocument:(NSNotification *)note
{
    ServiceFile *file = note.object;
    if (!file)
        return;
    [Account checkLoginStatus:^(BOOL isLoggedIn) {
        if (isLoggedIn)
            [self showViewControllerForServiceFile:file];
    }];
}

-(void)requestDidFail:(NSNotification *)note
{
    MPrintResponse *response = note.object;
    NSString *message = response.message;
    if (!message.length)
        return;
    
    // This is stupid. The server might return the message "The directory listing
    // could not be retrieved. Array", which is dumb because " Array" doesn't need
    // to be there.
    if ([message hasSuffix:@". Array"])
        message = [message substringToIndex:[message rangeOfString:@" Array"].location];
    
    [[[UIAlertView alloc] initWithTitle:message message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

-(void)connectionDidFail:(NSNotification *)note
{
    if (_connectionFailedAlertView)
        return;
    
    NSString *title = @"Unable to connect.";
    NSString *message = @"Please check your internet connection.";
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    _connectionFailedAlertView = view;
    [view show];
}

-(void)showViewControllerForServiceFile:(ServiceFile *)file
{
    PrintRequest *req = [PrintRequest printRequestWithDefaultOptions];
    req.file = file;
    
    PrintJobTableViewController *table = [[PrintJobTableViewController alloc] initWithPrintRequest:req];
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:table];
    controller.navigationBar.translucent = NO;
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.targetViewController presentViewController:controller animated:YES completion:nil];
}

-(UIViewController *)targetViewController
{
    UIApplication *application = [UIApplication sharedApplication];
    return application.keyWindow.rootViewController;
}

-(void)showLoginViewController
{
    LoginViewController *view = [[LoginViewController alloc] init];
    UIViewController *target = [self targetViewController];
    
    [target presentViewController:view animated:YES completion:nil];
}

@end
