//
//  UsageAllocation.m
//  BluePrinterCore
//
//  Created by David Quesada on 3/3/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "UsageAllocation.h"

@implementation UsageAllocation

-(id)initWithName:(NSString *)name allocation:(NSInteger)allocation
{
    self = [self init];
    if (self)
    {
        _name = name;
        _allocation = allocation;
    }
    return self;
}

@end
