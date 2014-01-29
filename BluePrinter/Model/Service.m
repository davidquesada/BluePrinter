//
//  Service.m
//  BluePrinter
//
//  Created by David Quesada on 1/29/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "Service.h"

@interface Service ()
@property (readwrite) NSString *description;
@property (readwrite) int connectedStatus;
@property (readwrite) NSString *name;
@end

@implementation Service

+(NSString *)fetchAPIEndpoint
{
    return @"/services";
}

-(BOOL)isConnected
{
    return self.connectedStatus != 0;
}

+(NSDictionary *)fieldConversions
{
    return @{
             @"description" : @"description",
             @"is_connected" : @"connectedStatus",
             @"name" : @"name",
             };
}

-(void)fetchDirectoryInfoForPath:(NSString *)path completion:(MPrintFetchHandler)completion
{
    
}

@end
