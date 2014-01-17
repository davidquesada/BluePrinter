//
//  MPrintRequest.m
//  BluePrinter
//
//  Created by David Paul Quesada on 1/14/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MPrintRequest.h"

@interface MPrintRequest ()

@property NSString *endpoint;
@property Method method;

@end

@implementation MPrintRequest

+(NSString *)baseURL
{
    return @"https://mprint.umich.edu";
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(instancetype)initWithEndpoint:(NSString *)endpoint method:(Method)method
{
    if ((self = [self init]))
    {
        self.endpoint = endpoint;
        self.method = method;
    }
    return self;
}

-(instancetype)initWithEndpoint:(NSString *)endpoint
{
    return self = [self initWithEndpoint:endpoint method:GET];
}

@end
