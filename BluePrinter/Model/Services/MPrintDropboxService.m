//
//  MPrintDropboxService.m
//  BluePrinter
//
//  Created by dquesada on 2/20/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MPrintDropboxService.h"

@implementation MPrintDropboxService

-(NSString *)name
{
    return @"dropbox";
}

-(NSString *)description
{
    return @"Dropbox";
}

-(ServiceType)type
{
    return ServiceTypeDropbox;
}

-(MPrintNetworkedServiceConnectionMethod)connectionMethod
{
    return MPrintNetworkedServiceConnectionMethodAuthenticated;
}

-(NSURL *)authorizationURL
{
    // This is a hack. For some reason (as of March 17), MPrint won't like it if
    // you try to activate the service by using the callback at /api/services/dropbox,
    // but will handle /settings/services/dropbox, which is an html frontend. So we
    // need to modify the URL to use the method that works.
    NSURL *url = [super authorizationURL];
    NSString *newString = [[url description] stringByReplacingOccurrencesOfString:@"api%2" withString:@"settings%2"];
    
    url = [NSURL URLWithString:newString];
    NSDebugLog(@"New URL for Dropbox Auth : %@", url);
    
    return url;
}

-(MPrintNetworkedServiceAuthResult)actionForMPrintURL:(NSURL *)url
{
    NSString *query = url.query;
    if (!query)
        return MPrintNetworkedServiceAuthResultNone;
    if ([query rangeOfString:@"oauth_token"].location != NSNotFound)
        return MPrintNetworkedServiceAuthResultApproved;
    if ([query rangeOfString:@"not_approved"].location != NSNotFound)
        return MPrintNetworkedServiceAuthResultDenied;
    return MPrintNetworkedServiceAuthResultNone;
}

@end
