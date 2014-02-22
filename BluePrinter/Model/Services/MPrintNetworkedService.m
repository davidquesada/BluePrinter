//
//  MPrintNetworkedService.m
//  BluePrinter
//
//  Created by dquesada on 2/20/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MPrintNetworkedService.h"
#import "MPrintRequest.h"
#import "MPrintResponse.h"
#import "ServiceFile.h"

@interface MPrintNetworkedService ()

-(NSURL *)urlForDirectoryAtPath:(NSString *)path;
-(NSURL *)urlForDisconnect;

@end

@implementation MPrintNetworkedService

-(NSString *)preparePathForDirectory:(NSString *)directory
{
    return directory;
}

-(NSURL *)urlForDirectoryAtPath:(NSString *)path
{
    path = [self preparePathForDirectory:path];
    
    // TODO: I'm not sure if this is the right method to encode the path.
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *url = [NSString stringWithFormat:@"https://mprint.umich.edu/api/services/%@?ls&path=%@", [self name], path];
    return [NSURL URLWithString:url];
}

-(ServiceFile *)fileFromJSONDictionary:(NSDictionary *)dict
{
    return [[ServiceFile alloc] initWithJSONDictionary:dict service:self];
}

-(void)willPerformRequest:(MPrintRequest *)request
{
}

-(void)didReceiveResponse:(MPrintResponse *)response
{
}

-(NSURL *)urlForDisconnect
{
    NSString *url = [NSString stringWithFormat:@"https://mprint.umich.edu/api/services/%@", self.name];
    return [NSURL URLWithString:url];
}

#pragma mark - Service Methods

-(void)fetchDirectoryInfoForPath:(NSString *)path completion:(MPrintFetchHandler)completion
{
    NSURL *url = [self urlForDirectoryAtPath:path];
    MPrintRequest *req = [[MPrintRequest alloc] initWithCustomURL:url method:GET];
    [self willPerformRequest:req];
    
    [req performWithCompletion:^(MPrintResponse *response) {
        
        [self didReceiveResponse:response];
        NSMutableArray *files = nil;
        if (response.success)
        {
            files = [[NSMutableArray alloc] initWithCapacity:response.count];
            for (NSDictionary *dict in response.results)
            {
                ServiceFile *file = [self fileFromJSONDictionary:dict];
                [files addObject:file];
            }
        }
        
        if (completion)
            completion(files, response);
        
    }];
}

-(BOOL)supportsDisconnect
{
    return YES;
}

-(void)disconnect:(void (^)())completion
{
    MPrintRequest *req = [[MPrintRequest alloc] initWithCustomURL:[self urlForDisconnect] method:DELETE];

    [req performWithCompletion:^(MPrintResponse *response) {
        
        // TODO: We actually want to refresh the status of the service after sending this request.
        // It would be simple to check the "success" status of the response, but we can't do that
        // because we're tentatively using a URL that returns an HTML page, so we can't easily grab
        // the success status. For now, assumed the disconnect succeeded.
        if (response.success)
            [self setValue:@(0) forKey:@"connectedStatus"];
        
        if (completion)
            completion();
        
    }];
}

@end
