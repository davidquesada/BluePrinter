//
//  MPrintLockerService.m
//  BluePrinterCore
//
//  Created by David Quesada on 2/21/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MPrintLockerService.h"

@implementation MPrintLockerService

-(NSString *)name
{
    return @"locker";
}

-(NSString *)description
{
    return @"MPrint Locker";
}

-(ServiceType)type
{
    return ServiceTypeLocker;
}

-(MPrintNetworkedServiceConnectionMethod)connectionMethod
{
    return MPrintNetworkedServiceConnectionMethodSimple;
}

-(void)connect:(void (^)())completion
{
    [super connect:^{
        [self refreshService:completion];
    }];
}

-(MPrintRequest *)requestForSimpleConnect
{
    NSURL *url = [NSURL URLWithString:@"https://mprint.umich.edu/settings/services/locker/enable"];
    MPrintRequest *req = [[MPrintRequest alloc] initWithCustomURL:url method:POST];
    [req addBodyValue:@"ifs" forKey:@"service"];
    [req addBodyValue:@"Enable" forKey:@"confirm"];
    return req;
}

@end
