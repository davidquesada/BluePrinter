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
    return 25;
}

+(instancetype)locationAtIndex:(int)index
{
    return nil;
}

+(void)refreshLocations:(void (^)(BOOL))completion
{
    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        completion(YES);
    });
    
    MPrintRequest *request = [[MPrintRequest alloc] initWithEndpoint:@"/queues"];
}

@end
