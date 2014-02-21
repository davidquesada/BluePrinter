//
//  MPrintResponse.m
//  BluePrinter
//
//  Created by David Paul Quesada on 1/14/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MPrintResponse.h"

MPrintResponse *lastSuccessfulResponse;

MPrintStatusCode statusCodeForStatusString(NSString *statusString)
{
    if (!statusString || [statusString isEqualToString:@"failure"])
        return MPrintStatusCodeFailed;
    if ([statusString isEqualToString:@"success"])
        return MPrintStatusCodeSuccess;
    return MPrintStatusCodeOther;
}

@interface MPrintResponse ()
{
    NSDictionary *_jsonObject;
}
@end

@implementation MPrintResponse

+(NSString *)lastUniqname
{
    return lastSuccessfulResponse.uniqname;
}

+(instancetype)successResponse
{
    MPrintResponse *response = [[MPrintResponse alloc] init];
    response.jsonObject = @{ @"status" : @"success" };
    return response;
}

#pragma mark - Properties

-(NSDictionary *)jsonObject
{
    return _jsonObject;
}

-(void)setJsonObject:(NSDictionary *)jsonObject
{
    _jsonObject = jsonObject;
    self.statusCode = statusCodeForStatusString(self.statusString);
    if (self.success)
        lastSuccessfulResponse = self;
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

-(NSString *)uniqname
{
    return [self.jsonObject valueForKey:@"uniqname"];
}

@end
