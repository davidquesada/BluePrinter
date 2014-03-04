//
//  Usage.m
//  BluePrinter
//
//  Created by David Quesada on 3/3/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "Usage.h"

@implementation Usage

+(NSString *)fetchAPIEndpoint
{
    return [NSString stringWithFormat:@"/users?account"];
}

-(instancetype)initWithJSONDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self)
    {
        NSDictionary *account = dictionary[@"account"];
        NSMutableArray *categories = [NSMutableArray new];
        id catdata = nil;
        if ((catdata = account[@"bw"]))
            [categories addObject:[[UsageCategory alloc] initWithJSONDictionary:catdata]];
        if ((catdata = account[@"color"]))
            [categories addObject:[[UsageCategory alloc] initWithJSONDictionary:catdata]];
        if ((catdata = account[@"poster"]))
            [categories addObject:[[UsageCategory alloc] initWithJSONDictionary:catdata]];
        _categories = [categories copy];
    }
    return self;
}

@end
