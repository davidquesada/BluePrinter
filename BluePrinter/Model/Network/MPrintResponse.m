//
//  MPrintResponse.m
//  BluePrinter
//
//  Created by David Paul Quesada on 1/14/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MPrintResponse.h"

MPrintStatusCode statusCodeForStatusString(NSString *statusString)
{
    if (!statusString || [statusString isEqualToString:@"failure"])
        return MPrintStatusCodeFailed;
    if ([statusString isEqualToString:@"success"])
        return MPrintStatusCodeSuccess;
    return MPrintStatusCodeOther;
}

@implementation MPrintResponse

+(instancetype)successResponse
{
    MPrintResponse *response = [[MPrintResponse alloc] init];
    response.jsonObject = @{ @"status" : @"success" };
    return response;
}

-(NSString *)statusString
{
    return [self.jsonObject valueForKey:@"status"];
}

-(BOOL)success
{
    return self.statusCode == MPrintStatusCodeSuccess;
}

-(NSInteger)count
{
    return [[self.jsonObject valueForKey:@"count"] integerValue];
}

-(NSArray *)results
{
    return [self.jsonObject valueForKey:@"result"];
}

-(NSString *)message
{
    return [self.jsonObject valueForKey:@"status_message"];
}

@end
