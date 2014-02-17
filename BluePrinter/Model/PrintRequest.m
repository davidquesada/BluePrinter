//
//  PrintRequest.m
//  BluePrinter
//
//  Created by David Quesada on 2/11/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "PrintRequest.h"
#import "ServiceFile.h"
#import "Service.h"
#import "MPrintRequest.h"
#import "MPrintResponse.h"


@interface PrintRequest ()

@property MPrintRequest *internalRequest;
@property NSMutableDictionary *requestDictionary;

-(void)createRequestDictionary;
-(void)attachFileToRequest;
-(void)attachLocalFileToRequest;
-(void)realSend:(void (^)(PrintJob *, MPrintResponse *))completion;
@end

@implementation PrintRequest

-(id)init
{
    self = [super init];
    if (self) {
        self.copies = 1;
    }
    return self;
}

-(void)send:(void (^)(PrintJob *, MPrintResponse *))completion
{
    [self realSend:completion];
}

-(void)realSend:(void (^)(PrintJob *, MPrintResponse *))completion
{
    MPrintRequest *printReq = [[MPrintRequest alloc] initWithEndpoint:@"/jobs" method:POST];
    self.internalRequest = printReq;
    
    NSMutableURLRequest *req = [printReq urlRequest];
    
    [self attachFileToRequest];
    [self createRequestDictionary];

    [self.requestDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [printReq addFormValue:obj forKey:key];
    }];
    
    NSLog(@"About to send print request.");
    
    [printReq performWithCompletion:^(MPrintResponse *response) {
        PrintJob *job = nil;
        if (completion)
            completion(job, response);
    }];
}

-(void)attachFileToRequest
{
    if (self.file.serviceType != ServiceTypeLocal)
    {
        NSLog(@"Only local files are supported for now.");
        return;
    }
    [self attachLocalFileToRequest];
}

-(void)attachLocalFileToRequest
{
    NSData *data = [self.file downloadFileContentsBlocking:nil];
    
    // Don't actually put the file in "file". So I can test the requests without actually
    // printing stuff every 5 minutes as I debug.
    [self.internalRequest addFormData:data forKey:@"file" withFilename:self.file.name contentType:nil];
}

-(void)createRequestDictionary
{
    id dict = @{
                @"queue" : self.printLocation.name,
                };
    
    self.requestDictionary = [dict mutableCopy];
}

@end
