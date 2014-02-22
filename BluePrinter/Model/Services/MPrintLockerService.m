//
//  MPrintLockerService.m
//  BluePrinter
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

@end
