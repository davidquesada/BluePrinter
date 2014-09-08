//
//  Location.m
//  BluePrinterCore
//
//  Created by David Paul Quesada on 1/14/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "Location.h"
#import "Network.h"

NSString * const MPrintDidRefreshLocationsNotification = @"MPrintDidRefreshLocationsNotification";

NSArray *locations;
NSArray *recentLocations;

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
    // Adding "list" to the url makes it return fewer attributes about each queue.
    // Less data, less conversion, less waste...
    [self fetchWithArguments:@{ @"list" : @"",
                                @"nosubqueues" : @"", } completion:^(NSMutableArray *objects, MPrintResponse *response) {
        if (response.success)
        {
            locations = objects;
            [[NSNotificationCenter defaultCenter] postNotificationName:MPrintDidRefreshLocationsNotification object:nil];
        }
        if (completion)
            completion(response.success);
    }];
}

+(NSArray *)recentLocations
{
    return recentLocations;
}

+(void)refreshRecentLocations:(void (^)(BOOL))completion
{
    [self fetchWithArguments:@{ @"list" : @"", @"recent" : @"" } completion:^(NSMutableArray *objects, MPrintResponse *response) {
        if (response.success)
        {
            recentLocations = objects;
            [[NSNotificationCenter defaultCenter] postNotificationName:MPrintDidRefreshLocationsNotification object:nil];
        }
        if (completion)
            completion(response.success);
    }];
}

-(instancetype)initWithJSONDictionary:(NSDictionary *)dictionary
{
    self = [super initWithJSONDictionary:dictionary];
    if (self)
    {
        _status = LocationStatusOK;
        NSString *reason = dictionary[@"state_reasons"];
        if ([reason hasSuffix:@"warning"] || [reason hasSuffix:@"error"])
            _status = LocationStatusError;
    }
    return self;
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
