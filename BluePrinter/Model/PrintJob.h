//
//  PrintJob.h
//  BluePrinter
//
//  Created by David Quesada on 2/11/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPrintObject.h"

extern NSString * const MPrintDidRefreshUserJobsNotification;

@interface PrintJob : MPrintObject

+(NSArray *)userJobs;
+(void)refreshUserJobs:(void (^)(BOOL success))completion;

@property(readonly) NSString *jobID;

@property(readonly) NSString *uniqname;
@property(readonly) NSDate *creationTime;
@property(readonly) NSString *name;
@property(readonly) NSString *printerDisplayName;
@property(readonly) NSString *printerName;

@property(readonly) NSInteger progress;
@property(readonly) BOOL cancellable; // returned as 1/0

// TODO: Figure out what the values for this are. ("completed", ...)
@property(readonly) NSString *state;

-(void)refresh:(MPrintFetchHandler)completion;
-(void)cancel:(MPrintFetchHandler)completion;

@end
