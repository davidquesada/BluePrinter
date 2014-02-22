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

@end
