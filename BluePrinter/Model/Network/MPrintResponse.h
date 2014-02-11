//
//  MPrintResponse.h
//  BluePrinter
//
//  Created by David Paul Quesada on 1/14/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MPrintStatusCode)
{
    MPrintStatusCodeSuccess = 0,
    MPrintStatusCodeFailed = 1,
    MPrintStatusCodeOther = 2,
};

MPrintStatusCode statusCodeForStatusString(NSString *statusString);

// JSON fields: count, exec_time, result (json rows), role, status, status_message, uniqname
// status:  'success', 'failure', (Any more?)
@interface MPrintResponse : NSObject

+(instancetype)successResponse;

@property NSData *data;
@property MPrintStatusCode statusCode;
@property NSDictionary *jsonObject;
@property (readonly) NSString *statusString;

@property (readonly) BOOL success;
@property (readonly) NSArray *results; // An array of JSON dictionaries;
@property (readonly) NSString *message;

@end
