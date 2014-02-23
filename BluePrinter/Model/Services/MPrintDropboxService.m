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

@end
