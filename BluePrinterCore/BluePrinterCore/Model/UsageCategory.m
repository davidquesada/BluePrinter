//
//  UsageCategory.m
//  BluePrinterCore
//
//  Created by David Quesada on 3/3/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "UsageCategory.h"
#import "UsageAllocation.h"

@implementation UsageCategory

-(instancetype)initWithJSONDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self)
    {
        _name = dictionary[@"name"];
        _unit = dictionary[@"unit"];
        _totalUsage = [dictionary[@"total_usage"] integerValue];
        _totalAllocation = [dictionary[@"total_allocation"] integerValue];
        
        NSMutableArray *allocations = [NSMutableArray new];
        NSDictionary *all = dictionary[@"service_allocations"];
        if (all.count && [all respondsToSelector:@selector(enumerateKeysAndObjectsUsingBlock:)])
            [all enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSString *name = key;
                NSInteger amount = [obj integerValue];
                UsageAllocation *alloc = [[UsageAllocation alloc] initWithName:name allocation:amount];
                [allocations addObject:alloc];
            }];
        
        _allocations = [allocations copy];
    }
    return self;
}

@end
