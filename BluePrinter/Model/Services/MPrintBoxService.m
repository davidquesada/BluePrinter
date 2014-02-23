//
//  MPrintBoxService.m
//  BluePrinter
//
//  Created by David Quesada on 2/21/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MPrintBoxService.h"

@implementation MPrintBoxService

-(NSString *)name
{
    return @"box";
}

-(NSString *)description
{
    return @"Box";
}

-(ServiceType)type
{
    return ServiceTypeBox;
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

@end
