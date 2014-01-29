//
//  MPrintObject.h
//  BluePrinter
//
//  Created by David Quesada on 1/28/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPrintResponse;

typedef void (^MPrintFetchHandler)(NSMutableArray *objects, MPrintResponse *response) ;

@interface MPrintObject : NSObject

-(instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;

#pragma mark - API's

+(void)fetchWithCompletion:(MPrintFetchHandler)completion;
+(void)fetchWithArguments:(NSDictionary *)args completion:(MPrintFetchHandler)completion;

#pragma mark - Override these in your subclasses

+(NSString *)fetchAPIEndpoint;
+(NSDictionary *)fieldConversions;

@end
