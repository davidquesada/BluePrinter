//
//  Location.m
//  BluePrinter
//
//  Created by David Paul Quesada on 1/14/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "Location.h"
#import "Network.h"

NSArray *locations;

@implementation Location

+(int)locationCount
{
    return locations.count;
}

+(instancetype)locationAtIndex:(int)index
{
    return locations[index];
}

+(NSArray *)allLocations
{
    return locations;
}

+(void)refreshLocations:(void (^)(BOOL))completion
{    
    [self fetchWithCompletion:^(NSMutableArray *objects, MPrintResponse *response) {
        if (response.success)
            locations = objects;
        if (completion)
            completion(response.success);
    }];
}

#pragma mark - MPrintObject fields

+(NSString *)fetchAPIEndpoint
{
    return @"/queues";
}

+(NSDictionary *)fieldConversions
{
    return @{
             @"name" : @"name",
             @"display_name" : @"displayName",
             @"sub_campus_area" : @"subCampusArea",
             @"location" : @"location",
             };
}

@end
