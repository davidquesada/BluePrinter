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

#pragma mark - Service Methods

-(void)fetchDirectoryInfoForPath:(NSString *)path completion:(MPrintFetchHandler)completion
{
    NSURL *url = [self urlForDirectoryAtPath:path];
    MPrintRequest *req = [[MPrintRequest alloc] initWithCustomURL:url method:GET];
    
    [req performWithCompletion:^(MPrintResponse *response) {
        
        NSMutableArray *files = nil;
        if (response.success)
        {
            files = [[NSMutableArray alloc] initWithCapacity:response.count];
            for (NSDictionary *dict in response.results)
            {
                ServiceFile *file = [[ServiceFile alloc] initWithJSONDictionary:dict service:self];
                [files addObject:file];
            }
        }
        
        if (completion)
            completion(files, response);
        
    }];
}

@end
