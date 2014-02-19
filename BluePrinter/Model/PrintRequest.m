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

-(id)orientationValue;
-(id)doubleSidedValue;
-(id)fitToPageValue;

@end

@implementation PrintRequest

-(id)init
{
    self = [super init];
    if (self) {
        self.copies = 1;
        self.pagesPerSheet = 1;
        self.fitToPage = YES;
        self.orientation = MPOrientationPortrait;
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
    
    [self attachFileToRequest];
    [self createRequestDictionary];

    [self.requestDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        // Account for some NSNumbers in the request dictionary.
        if (![obj isKindOfClass:[NSString class]])
            obj = [obj description];
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
    
    id d = @{
                @"copies" : @(self.copies),
                @"queue" : self.printLocation.name,
                @"orientation" : [self orientationValue],
                @"sides" : [self doubleSidedValue],
                @"pages_per_sheet" : @(self.pagesPerSheet),

//              @"range" : @"1-45",
                
//              @"size" : @[ @"letter", @"tabloid", @"custom" ],
//              @"size_width" : @(8.5),
//              @"size_height" : @(11),

                @"scale" : [self fitToPageValue],
                };
    
    NSMutableDictionary *dict = [d mutableCopy];
    
    if (self.pageRange.length)
        dict[@"range"] = self.pageRange;
    
    self.requestDictionary = dict;
}

-(id)orientationValue
{
    if (_orientation == MPOrientationPortrait)
        return @"portrait";
    if (_orientation == MPOrientationLandscape)
        return @"landscape";
    return [NSNull null];
}

-(id)doubleSidedValue
{
    if (_doubleSided == MPDoubleSidedNo)
        return @"one-sided";
    if (_doubleSided == MPDoubleSidedShortEdge)
        return @"two-sided-short-edge";
    if (_doubleSided == MPDoubleSidedLongEdge)
        return @"two-sided-long-edge";
    return [NSNull null];
}

-(id)fitToPageValue
{
    if (_fitToPage)
        return @"on";
    return @"off";
}

@end

@implementation PrintRequest (Descriptions)

-(NSString *)orientationDescription
{
    if (_orientation == MPOrientationLandscape)
        return @"Landscape";
    if (_orientation == MPOrientationPortrait)
        return @"Portrait";
    return nil;
}

-(NSString *)doubleSidedDescription
{
    if (_doubleSided == MPDoubleSidedNo)
        return @"No";
    if (_doubleSided == MPDoubleSidedLongEdge)
        return @"Bind on long edge";
    if (_doubleSided == MPDoubleSidedShortEdge)
        return @"Bind on short edge";
    return nil;
}

@end
