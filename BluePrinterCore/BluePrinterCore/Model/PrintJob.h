//
//  PrintJob.h
//  BluePrinterCore
//
//  Created by David Quesada on 2/11/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPrintObject.h"

extern NSString * const MPrintDidRefreshUserJobsNotification;

typedef NS_ENUM(NSInteger, PrintJobState)
{
    PrintJobStateConverting,
    PrintJobStateProcessing,
    PrintJobStateCompleted,
    PrintJobStateFailed,
    PrintJobStateCancelled,
};

@interface PrintJob : MPrintObject

+(NSArray *)userJobs;
+(instancetype)userJobWithID:(NSString *)jobID;
+(void)refreshUserJobs:(void (^)(BOOL success))completion;
+(void)removeUserJobs;

@property(readonly) NSString *jobID;

@property(readonly) NSString *uniqname;
@property(readonly) NSDate *creationTime;
@property(readonly) NSString *name;
@property(readonly) NSString *printerDisplayName;
@property(readonly) NSString *printerName;

@property(readonly) NSInteger progress;
@property(readonly) BOOL cancellable; // returned as 1/0

// TODO: Figure out what the values for this are. ("completed", "failed", "cancelled")
@property(readonly) PrintJobState state;

// Whether the job is in a working state where its status may change.
// Currently corresponds to either 'processing' or 'converting'.
@property(readonly) BOOL isPending;

@property(readonly) NSString *stateDescription;

-(void)refresh:(MPrintFetchHandler)completion;
-(void)cancel:(MPrintFetchHandler)completion;

@end
