//
//  AppDelegate.m
//  BluePrinter
//
//  Created by David Paul Quesada on 1/14/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "AppDelegate.h"
#import "NotificationManager.h"
#import "UserDefaults.h"
#import "SVProgressHUD.h"
#import "LegacySupport.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

AppDelegate *sharedDelegate;

@interface AppDelegate ()<UINavigationControllerDelegate, LoginViewControllerDelegate>
{
    BOOL _hasRegisteredNotifications;
    UIBackgroundTaskIdentifier _logoutTask;
    ServiceFile *_importedFile;
    __weak UIAlertView *_connectionFailedAlertView;
    __weak LoginViewController *_presentedLoginViewController;
}

-(void)didLogIn:(NSNotification *)note;
-(void)didImportDocument:(NSNotification *)note;
-(void)requestDidFail:(NSNotification *)note;
-(void)connectionDidFail:(NSNotification *)note;
-(void)addv6Appearance:(UIApplication *)application;
-(void)addv7Appearance:(UIApplication *)application;

-(void)showJobsTabOfApplication:(UIApplication *)application;

-(UIViewController *)targetViewController;
-(void)registerForNotifications;

-(void)clearTemporaryDocumentsDirectory;

-(void)presentLoginViewController;

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
    
    [self clearTemporaryDocumentsDirectory];
    
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

-(void)addv6Appearance:(UIApplication *)application
{
    
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

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NotificationManager defaultNotificationManager] applicationWillEnterBackground];
    
    if ([UserDefaults shouldLogOutWhenLeavingApp])
    {
        _logoutTask = UIBackgroundTaskInvalid;
        _logoutTask = [application beginBackgroundTaskWithExpirationHandler:^{
            NSDebugLog(@"Ending logout background task due to expiration.");
            [application endBackgroundTask:_logoutTask];
            _logoutTask = UIBackgroundTaskInvalid;
        }];
        
        [Account logout:^(BOOL success) {
            NSDebugLog(@"Finished logout.");
            
            // Wait a second so notification observers can get the message.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSDebugLog(@"Ending logout background task.");
                [application endBackgroundTask:_logoutTask];
                _logoutTask = UIBackgroundTaskInvalid;
            });
        }];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NotificationManager defaultNotificationManager] applicationWillEnterForeground];
}

-(void)importLocalFileAtPath:(NSString *)path
{
    // If the user has selected to save imported files, hand the responsibility off to
    // the local file service, which will take care of putting the file in a good place.
    if ([UserDefaults shouldSaveImportedFiles])
    {
        [[Service localService] importFileAtLocalPath:path];
        return;
    }
    
    // Otherwise, we're going to move the file to a temporary location.
    
    NSString *newpath = [NSTemporaryDirectory() stringByAppendingPathComponent:[path lastPathComponent]];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // If we have duplicate filenames, get rid of the old version.
    if ([manager fileExistsAtPath:newpath])
        [manager removeItemAtPath:newpath error:nil];
    
    NSError *error = nil;
    [manager moveItemAtPath:path toPath:newpath error:&error];
    
    if (error)
        NSLog(@"Error moving file to temp directory: %@", error);
    
    ServiceFile *file = [[ServiceFile alloc] initWithFileAtPath:newpath];
    [self didImportServiceFile:file];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [self registerForNotifications];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *path = [url path];
        [self importLocalFileAtPath:path];
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
    [self didImportServiceFile:file];
}

-(void)didImportServiceFile:(ServiceFile *)file
{
    _importedFile = file;
    
    ImportAction action = [UserDefaults importAction];
    if (action == ImportActionNone)
        return;
    
    [SVProgressHUD show];
    [Account checkLoginStatus:^(BOOL isLoggedIn) {
        [SVProgressHUD dismiss];
        if (isLoggedIn)
            [self presentViewControllerForImportedFile];
        else if (action == ImportActionPrintAlways)
            [self presentLoginViewController];
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

-(void)presentViewControllerForImportedFile
{
    PrintRequest *req = [PrintRequest printRequestWithDefaultOptions];
    req.file = _importedFile;
    
    PrintJobTableViewController *table = [[PrintJobTableViewController alloc] initWithPrintRequest:req];
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:table];
    controller.navigationBar.translucent = NO;
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.targetViewController presentViewController:controller animated:YES completion:nil];
}

-(void)presentLoginViewController
{
    if (_presentedLoginViewController)
        return;
    
    LoginViewController *controller = [[LoginViewController alloc] init];
    _presentedLoginViewController = controller;
    controller.delegate = self;
    
    [self.targetViewController presentViewController:controller animated:YES completion:nil];
}

-(void)loginViewController:(LoginViewController *)controller didDismissWithLoginResult:(BOOL)loggedIn
{
    if (loggedIn)
        [self presentViewControllerForImportedFile];
    _importedFile = nil;
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

-(void)clearTemporaryDocumentsDirectory
{
    NSDebugLog(@"Clearing temporary directory.");
    
    NSString *directory = NSTemporaryDirectory();
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *filenames = [manager contentsOfDirectoryAtPath:directory error:nil];
    
    if (!filenames.count)
        return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        for (NSString *filename in filenames)
        {
            NSError *error = nil;
            NSString *fullfilename = [directory stringByAppendingPathComponent:filename];
            [manager removeItemAtPath:fullfilename error:&error];
            
            if (error)
                NSLog(@"Failed to remove item from temporary directory: %@", error);
        }
        
    });
}

@end
