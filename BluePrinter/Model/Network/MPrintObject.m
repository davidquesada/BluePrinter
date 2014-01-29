//
//  MPrintObject.m
//  BluePrinter
//
//  Created by David Quesada on 1/28/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MPrintObject.h"
#import "MPrintRequest.h"
#import "MPrintResponse.h"

static NSString * const MPrintObjectDefaultAPIEndpoint = @"You must subclass MPrintObject and define an API endpoint before fetching";

@interface MPrintObject ()
//+(void)doCompletionHandler:(MPrintFetchHandler)completion withObjects:(NSMutableArray *)
+(NSMutableArray *)arrayWithJSONDictionaries:(NSArray *)dictionaries;
-(instancetype)initWithJSONDictionary:(NSDictionary *)dictionary conversions:(NSDictionary *)conversions;
@end

@implementation MPrintObject

+(void)fetchWithCompletion:(MPrintFetchHandler)completion
{
    [self fetchWithArguments:nil completion:completion];
}

+(void)fetchWithArguments:(NSDictionary *)args completion:(MPrintFetchHandler)completion
{
    if ([self fetchAPIEndpoint] == MPrintObjectDefaultAPIEndpoint)
        @throw MPrintObjectDefaultAPIEndpoint;
    
    //TODO: Actually do something with the arguments.
    MPrintRequest *request = [[MPrintRequest alloc] initWithEndpoint:[self fetchAPIEndpoint]];
    [request performWithCompletion:^(MPrintResponse *response) {
        
        NSMutableArray *objects = nil;
        if (response.success)
        {
            objects = [self arrayWithJSONDictionaries:response.results];
        }
        
        if (completion)
            completion(objects, response);
    }];
}

+(NSMutableArray *)arrayWithJSONDictionaries:(NSArray *)dictionaries
{
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:[dictionaries count]];
    NSDictionary *conversions = [self fieldConversions];
    
    for (NSDictionary *record in dictionaries)
    {
        MPrintObject *object = [[self alloc] initWithJSONDictionary:record conversions:conversions];
        [results addObject:object];
    }
    
    return results;
}

-(instancetype)initWithJSONDictionary:(NSDictionary *)dictionary
{
    return self = [self init];
}

-(instancetype)initWithJSONDictionary:(NSDictionary *)dictionary conversions:(NSDictionary *)conversions
{
    if ((self = [self initWithJSONDictionary:dictionary]))
    {
        [conversions enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            id val = [dictionary valueForKey:key];
            if (val && (val != [NSNull null]))
                [self setValue:val forKey:obj];
        }];
    }
    return self;
}

#pragma mark - Overrideable Things.

+(NSString *)fetchAPIEndpoint
{
    return MPrintObjectDefaultAPIEndpoint;
}

/* A dictionary where the keys are the names of properties of the JSON object, and the values are the names of properties of the Objective-C object.
 */
+(NSDictionary *)fieldConversions
{
    return @{};
}

@end
