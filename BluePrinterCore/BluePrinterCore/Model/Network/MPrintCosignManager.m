//
//  MPrintCosignManager.m
//  BluePrinterCore
//
//  Created by David Quesada on 2/17/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MPrintCosignManager.h"
#import "Account.h"

NSString * const MPrintUserDidLogInNotification = @"MPrintUserDidLogInNotification";
NSString * const MPrintUserDidLogOutNotification = @"MPrintUserDidLogOutNotification";

static NSString * const MPCMEnabledKey = @"MPCMEnabled";
static NSString * const MPCMCosignKey = @"MPCMCosign";
static NSString * const MPCMMPrintCosignKey = @"MPCMMPrintCosign";

static NSString *getCookieValue(NSString *domain, NSString *name);

@interface MPrintCosignManager ()

+(void)attemptRestoreCosign;

@end

@implementation MPrintCosignManager

+(void)load
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    if (![def objectForKey:MPCMEnabledKey])
        [self setPersistentCosignEnabled:YES];
    
    if (![self isPersistentCosignEnabled])
        return;
    
    [self attemptRestoreCosign];
}

+(void)attemptRestoreCosign
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSHTTPCookieStorage *cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    NSString *cosign = [def stringForKey:MPCMCosignKey];
    NSString *mprintcosign = [def stringForKey:MPCMMPrintCosignKey];
    
    if (!cosign || !mprintcosign)
    {
        NSDebugLog(@"Stored cosign values not found.");
        return;
    }
    
    NSHTTPCookie *cookie;
    
    cookie = [[NSHTTPCookie alloc] initWithProperties:@{
                                                      NSHTTPCookieDomain : @"weblogin.umich.edu",
                                                      NSHTTPCookieName : @"cosign",
                                                      NSHTTPCookieValue : cosign,
                                                      NSHTTPCookieSecure : @(YES),
                                                      NSHTTPCookiePath : @"/"
                                                      }];
    [cookieStore setCookie:cookie];
    
    cookie = [[NSHTTPCookie alloc] initWithProperties:@{
                                                        NSHTTPCookieDomain : @"mprint.umich.edu",
                                                        NSHTTPCookieName : @"cosign-mprint",
                                                        NSHTTPCookieValue : mprintcosign,
                                                        NSHTTPCookieSecure : @(YES),
                                                        NSHTTPCookiePath : @"/"
                                                        }];
    [cookieStore setCookie:cookie];
    
    [Account checkLoginStatus:^(BOOL isLoggedIn) {
        if (isLoggedIn)
            [self userDidLogIn];
    }];
}

+(void)userDidLogIn
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MPrintUserDidLogInNotification object:nil];
    
    if (![self isPersistentCosignEnabled])
        return;
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSString *cosign = getCookieValue(@"https://weblogin.umich.edu", @"cosign");
    NSString *mprintcosign = getCookieValue(@"https://mprint.umich.edu", @"cosign-mprint");
    
    NSDebugLog(@"Storing values (CS,CS-MP) = (%@, %@)", cosign, mprintcosign);
    
    if (!cosign || !mprintcosign)
        NSDebugLog(@"Unable to retrieve cosign values after login!");
    
    [def setObject:cosign forKey:MPCMCosignKey];
    [def setObject:mprintcosign forKey:MPCMMPrintCosignKey];
    [def synchronize];
}

+(void)userDidLogOut
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MPrintUserDidLogOutNotification object:nil];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def removeObjectForKey:MPCMEnabledKey];
    [def removeObjectForKey:MPCMCosignKey];
    [def removeObjectForKey:MPCMMPrintCosignKey];
    [def synchronize];
    
    NSHTTPCookieStorage *store = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in store.cookies.copy)
    {
        if ([cookie.name isEqualToString:@"cosign"] || [cookie.name isEqualToString:@"cosign-mprint"])
            [store deleteCookie:cookie];
    }
}

+(BOOL)isPersistentCosignEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:MPCMEnabledKey];
}

+(void)setPersistentCosignEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:MPCMEnabledKey];
    if (!enabled)
        [self userDidLogOut];
}

@end

NSString *getCookieValue(NSString *domain, NSString *name)
{
    NSHTTPCookieStorage *store = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSURL *url = [NSURL URLWithString:domain];
    NSArray *cookies = [store cookiesForURL:url];
    
    for (NSHTTPCookie *cookie in cookies)
    {
        if ([cookie.name isEqualToString:name])
            return cookie.value;
    }
    
    return nil;
}
