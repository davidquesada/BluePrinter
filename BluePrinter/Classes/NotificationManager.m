//
//  NotificationManager.m
//  BluePrinter
//
//  Created by David Quesada on 3/18/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "NotificationManager.h"
#import "MPrint.h"

@interface NotificationManager ()
{
    BOOL _needsToDoFirstRefreshAfterPrint;
    BOOL _handleUserJobsRefresh;
    // A set of job ID's
    NSSet *_pendingJobs;
    NSSet *_lastJobs;
    
    dispatch_semaphore_t _pendingJobsSemaphore;
    NSObject *_syncObject;
    
    UIBackgroundTaskIdentifier _backgroundTaskIdentifier;
}

-(void)handleUserLogout;
-(NSSet *)jobIDsForJobs:(NSArray *)jobs;
-(NSMutableArray *)findNewlyCompletedJobs;
-(NSMutableArray *)findPendingJobs;
-(void)updatePendingJobIDs:(NSArray *)pendingJobs;

-(void)beginBackgroundTask;
-(void)endBackgroundTask;

-(void)notifyForCompletedJobs:(NSArray *)jobs;
-(void)notifyForCompletedJob:(PrintJob *)job;

// The function that runs in the polling thread.
-(void)pollJobs;

-(void)didSendPrintRequest:(NSNotification *)note;
-(void)didRefreshUserJobs:(NSNotification *)note;
-(void)didLogOut:(NSNotification *)note;

@end

@implementation NotificationManager

+(instancetype)defaultNotificationManager
{
    static NotificationManager *mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[NotificationManager alloc] init];
    });
    return mgr;
}

+(void)load
{
    [self defaultNotificationManager];
}

-(id)init
{
    self = [super init];
    if (!self)
        return nil;
    
    _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    _pendingJobsSemaphore = dispatch_semaphore_create(0);
    _syncObject = [NSObject new];
    [NSThread detachNewThreadSelector:@selector(pollJobs) toTarget:self withObject:nil];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(didSendPrintRequest:) name:PrintRequestDidSendNotification object:nil];
    [center addObserver:self selector:@selector(didRefreshUserJobs:) name:MPrintDidRefreshUserJobsNotification object:nil];
    [center addObserver:self selector:@selector(didLogOut:) name:MPrintUserDidLogOutNotification object:nil];
     
    return self;
}

#pragma mark - Public Methods

-(void)applicationWillEnterBackground
{
    NSDebugLog(@"applicationWillEnterBackground");
    if (_pendingJobs.count || _needsToDoFirstRefreshAfterPrint)
        [self beginBackgroundTask];
}

-(void)applicationWillEnterForeground
{
    NSDebugLog(@"applicationWillEnterForeground");
    [self endBackgroundTask];
}

#pragma mark - Methods

-(void)handleUserLogout
{
    _pendingJobs = nil;
    _lastJobs = nil;
}

-(NSSet *)jobIDsForJobs:(NSArray *)jobs
{
    static NSString *jobIDKey = nil;
    if (!jobIDKey)
        jobIDKey = NSStringFromSelector(@selector(jobID));
    
    NSArray *jobIDs = [jobs valueForKey:jobIDKey];
    NSSet *set = [NSSet setWithArray:jobIDs];
    return set;
}

-(NSMutableArray *)findNewlyCompletedJobs
{
    NSMutableArray *completedJobs = [NSMutableArray new];
    for (PrintJob *job in [PrintJob userJobs])
    {
        if (!job.isPending)
        {
            if ([_pendingJobs containsObject:job.jobID])
            {
                NSDebugLog(@"Found newly completed job: %@", job.name);
                [completedJobs addObject:job];
            }
        }
    }
    return completedJobs;
}

-(NSMutableArray *)findPendingJobs
{
    NSMutableArray *pendingJobs = [NSMutableArray new];
    
    for (PrintJob *job in [PrintJob userJobs])
        if (job.isPending)
            [pendingJobs addObject:job];
    
    return pendingJobs;
}

-(void)updatePendingJobIDs:(NSArray *)pendingJobs
{
    _pendingJobs = [self jobIDsForJobs:pendingJobs];
}

-(void)notifyForCompletedJobs:(NSArray *)jobs
{
    for (PrintJob *job in jobs)
        [self notifyForCompletedJob:job];
}

-(void)notifyForCompletedJob:(PrintJob *)job
{
    static NSDictionary *texts = nil;
    if (!texts)
        texts = @{ @(PrintJobStateCancelled) : @"\"%@\" has been cancelled.",
                   @(PrintJobStateCompleted) : @"\"%@\" has finished printing.",
                   @(PrintJobStateFailed) : @"\"%@\" has failed to print.",
                   };
    
    
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.soundName = UILocalNotificationDefaultSoundName;
    
    // We need some info in this dictionary so that we are able to tell in the
    // applicationDidFinishLaunchingWithOptions that we launched by tapping a notification.
    note.userInfo = @{ @"job_id" : job.jobID };
    
    NSString *docname = [job.name stringByReplacingOccurrencesOfString:@"%" withString:@"%%"];
    if (docname.length > 40)
        docname = [[docname substringToIndex:40] stringByAppendingString:@"..."];
    
    NSString *fmt = texts[@(job.state)];
    note.alertBody = [NSString stringWithFormat:fmt, docname];
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        docname = [docname stringByReplacingOccurrencesOfString:@"%%" withString:@"%"];
        NSString *message = [NSString stringWithFormat:fmt, docname];
        [[[UIAlertView alloc] initWithTitle:message message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    NSDebugLog(@"Presenting local notification: %@", docname);
    [[UIApplication sharedApplication] presentLocalNotificationNow:note];
}

-(void)beginBackgroundTask
{
    if (_backgroundTaskIdentifier != UIBackgroundTaskInvalid)
        return;
    
    NSDebugLog(@"Beginning background task for job refresh.");
    _backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"JobRefreshingTask" expirationHandler:^{
        NSDebugLog(@"About to end background task due to task expiration.");
        [self endBackgroundTask];
    }];
}

-(void)endBackgroundTask
{
    if (_backgroundTaskIdentifier == UIBackgroundTaskInvalid)
        return;
    
    NSDebugLog(@"Ending background task for job refresh.");
    [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskIdentifier];
    _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
}

#pragma mark - Thread Functions

// TODO: It's useless in practicality, but having a way to cancel this thread
// on deallocation of the manager object would be "good practice", so we're not
// just leaving theads all over the place.
-(void)pollJobs
{
    [[NSThread currentThread] setName:@"NotificationManager Jobs Poll Thread"];
    
    NSDebugLog(@"Beginning Jobs Poll Thread");
    while (true)
    {
        
    waitForNewJobs:
        dispatch_semaphore_wait(_pendingJobsSemaphore, DISPATCH_TIME_FOREVER);
        
        NSDebugLog(@"PollThread: pendingJobsSemaphore has been triggered.");
        
        while (true)
        {
            NSDebugLog(@"Polling jobs in background thread.");
            [PrintJob refreshUserJobs:nil];
            
            // Give the network call some time to refresh
            [NSThread sleepForTimeInterval:4.0];
            

            for (PrintJob *job in [PrintJob userJobs])
                if (job.isPending)
                    goto stillHasPendingJobs;
            
            NSDebugLog(@"Ran out of pending jobs. Going to wait for semaphore.");
            goto waitForNewJobs;
            
        stillHasPendingJobs:
            
            // Sleep some more
            [NSThread sleepForTimeInterval:2.0];
        }
    }
}

#pragma mark - Notification Handlers

-(void)didSendPrintRequest:(NSNotification *)note
{
    _needsToDoFirstRefreshAfterPrint = YES;
    
    // It takes an annoying amount of time until the print document actually appears.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDebugLog(@"Refreshing jobs after sending print job.");
        [PrintJob refreshUserJobs:^(BOOL success) {
            _handleUserJobsRefresh = success;
        }];
    });
}

-(void)didLogOut:(NSNotification *)note
{
    [self handleUserLogout];
}

-(void)didRefreshUserJobs:(NSNotification *)note
{
    NSMutableArray *completedJobs = [self findNewlyCompletedJobs];
    NSMutableArray *pendingJobs = [self findPendingJobs];
    NSSet *newJobIDs = [self jobIDsForJobs:[PrintJob userJobs]];

    // This may be necessary for certain cases, like when documents fail immediately.
    if (_lastJobs)
    {
        // See if there are any jobs that just came in, that we weren't able to
        // view long enough to see them change from pending to completed.
        for (NSString *jobID in newJobIDs)
        {
            if ([_lastJobs containsObject:jobID])
                continue;
            PrintJob *job = [PrintJob userJobWithID:jobID];
            if (!job)
                continue;
            if (job.isPending)
                [pendingJobs addObject:job];
            else
                [completedJobs addObject:job];
        }
    }
    
    _lastJobs = newJobIDs;
    [self updatePendingJobIDs:pendingJobs];
    [self notifyForCompletedJobs:completedJobs];
    
    if (_needsToDoFirstRefreshAfterPrint)
        dispatch_semaphore_signal(_pendingJobsSemaphore);
    _needsToDoFirstRefreshAfterPrint = NO;
}

@end
