//
//  MPrintDriveService.m
//  BluePrinterCore
//
//  Created by David Quesada on 2/20/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MPrintDriveService.h"

@implementation MPrintDriveService

-(NSString *)name
{
    return @"drive";
}

-(NSString *)description
{
    return @"Google Drive";
}

-(ServiceType)type
{
    return ServiceTypeDrive;
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
    if ([query rangeOfString:@"code"].location != NSNotFound)
        return MPrintNetworkedServiceAuthResultApproved;
    if ([query rangeOfString:@"access_denied"].location != NSNotFound)
        return MPrintNetworkedServiceAuthResultDenied;
    return MPrintNetworkedServiceAuthResultNone;
}

-(NSString *)preparePathForDirectory:(NSString *)directory
{
    // For some reason, the Google Drive service doesn't like / as a path.
    if ([directory isEqualToString:@"/"])
        return @"";
    return directory;
}

@end
