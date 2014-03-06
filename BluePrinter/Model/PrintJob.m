//
//  PrintJob.m
//  BluePrinter
//
//  Created by David Quesada on 2/11/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "PrintJob.h"
#import "MPrintRequest.h"
#import "MPrintResponse.h"

NSString * const MPrintDidRefreshUserJobsNotification = @"MPrintDidRefreshUserJobsNotification";

NSArray *userJobs;

@interface PrintJob ()

@property(readwrite) NSString *jobID;

@property(readwrite) NSString *uniqname;
@property(readwrite) NSDate *creationTime;
@property(readwrite) NSString *name;
@property(readwrite) NSString *printerDisplayName;
@property(readwrite) NSString *printerName;
@property(readwrite) NSInteger progress;
@property(readwrite) BOOL cancellable;
@property(readwrite) PrintJobState state;

-(void)populateWithJSONDictionary:(NSDictionary *)dictionary;
-(NSString *)updateAPIEndpoint;
-(NSString *)cancelAPIEndpoint;

@end

@implementation PrintJob

+(NSString *)fetchAPIEndpoint
{
    return @"/jobs";
}

+(NSArray *)userJobs
{
    return userJobs;
}

+(void)refreshUserJobs:(void (^)(BOOL))completion
{
    [self fetchWithCompletion:^(NSMutableArray *objects, MPrintResponse *response) {
        if (response.success)
            userJobs = objects;
        if (completion)
            completion(response.success);
        if (response.success)
            [[NSNotificationCenter defaultCenter] postNotificationName:MPrintDidRefreshUserJobsNotification object:nil];
    }];
}

+(void)loadFakeData:(void (^)(BOOL))completion
{
    NSMutableArray *jobs = [NSMutableArray new];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"name"] = @"DocumentTitle.pdf";
    dict[@"printer_display_name"] = @"Duderstadt Library";
    
    dict[@"state"] = @"converting";
    [jobs addObject:[[PrintJob alloc] initWithJSONDictionary:dict]];
    
    dict[@"state"] = @"processing";
    [jobs addObject:[[PrintJob alloc] initWithJSONDictionary:dict]];
    
    dict[@"state"] = @"completed";
    [jobs addObject:[[PrintJob alloc] initWithJSONDictionary:dict]];
    
    dict[@"state"] = @"cancelled";
    [jobs addObject:[[PrintJob alloc] initWithJSONDictionary:dict]];
    
    dict[@"state"] = @"failed";
    [jobs addObject:[[PrintJob alloc] initWithJSONDictionary:dict]];
    
    userJobs = jobs;
    if (completion)
        completion(YES);
    [[NSNotificationCenter defaultCenter] postNotificationName:MPrintDidRefreshUserJobsNotification object:nil];
}

-(instancetype)initWithJSONDictionary:(NSDictionary *)dictionary
{
    if ((self = [super initWithJSONDictionary:dictionary]))
        [self populateWithJSONDictionary:dictionary];
    return self;
}

-(void)populateWithJSONDictionary:(NSDictionary *)dictionary
{
    static NSDateFormatter *formatter = nil;
    if (!formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
//        formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    
    static NSDictionary *stateDict = nil;
    if (!stateDict)
        stateDict = @{
                      @"converting" : @(PrintJobStateConverting),
                      @"processing" : @(PrintJobStateProcessing),
                      @"completed" : @(PrintJobStateCompleted),
                      @"cancelled" : @(PrintJobStateCancelled),
                      @"failed" : @(PrintJobStateFailed),
                      };
    
    self.uniqname = dictionary[@"uniqname"];
    self.jobID = dictionary[@"id"];
    self.creationTime = [formatter dateFromString:dictionary[@"creation_time"]];
    self.name = dictionary[@"name"];
    self.printerDisplayName = dictionary[@"printer_display_name"];
    self.printerName = dictionary[@"printer_name"];
    self.progress = [dictionary[@"progress"] integerValue];
    self.cancellable = (BOOL)[dictionary[@"cancellable"] intValue];
    self.state = (PrintJobState)[stateDict[dictionary[@"state"]] integerValue];
}

-(NSString *)updateAPIEndpoint
{
    return [NSString stringWithFormat:@"/jobs/%@", self.jobID];
}

-(void)refresh:(MPrintFetchHandler)completion
{
    [self.class fetchWithEndpoint:[self updateAPIEndpoint] completion:^(NSMutableArray *objects, MPrintResponse *response) {
        
        if (response.success && (response.results.count == 1))
        {
            [self populateWithJSONDictionary:[response.results firstObject]];
        }
        
        if (completion)
            completion(objects, response);
    }];
}

-(NSString *)cancelAPIEndpoint
{
    return [NSString stringWithFormat:@"/jobs/%@", self.jobID];
}

-(void)cancel:(MPrintFetchHandler)completion
{
    MPrintRequest *req = [[MPrintRequest alloc] initWithEndpoint:[self cancelAPIEndpoint] method:DELETE];
    [req performWithCompletion:^(MPrintResponse *response) {
        if (completion)
            completion(nil, response);
    }];
}

-(NSString *)stateDescription
{
    static NSDictionary *dict = nil;
    if (!dict)
        dict = @{ @(PrintJobStateCancelled) : @"Cancelled",
                  @(PrintJobStateCompleted) : @"Completed",
                  @(PrintJobStateConverting) : @"Converting",
                  @(PrintJobStateFailed) : @"Failed",
                  @(PrintJobStateProcessing) : @"Processing",
                  };
    return dict[@(self.state)];
}

@end
