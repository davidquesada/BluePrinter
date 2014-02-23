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
