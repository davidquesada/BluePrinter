//
//  MPrintIFSService.m
//  BluePrinter
//
//  Created by David Quesada on 2/20/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MPrintIFSService.h"
#import "MPrintRequest.h"
#import "MPrintResponse.h"
#import "ServiceFile.h"

@interface MPrintIFSService ()
{
    NSString *_prefix;
}

-(NSString *)afsPrefix;
@end

/*
 For the IFS service, paths for files must be prepended with "/afs/umich.edu/user/u/n/uniqname".
 */
@implementation MPrintIFSService

-(NSString *)name
{
    return @"ifs";
}

-(NSString *)description
{
    return @"MFile IFS";
}

-(ServiceType)type
{
    return ServiceTypeIFS;
}

-(MPrintNetworkedServiceConnectionMethod)connectionMethod
{
    return MPrintNetworkedServiceConnectionMethodSimple;
}

-(NSString *)afsPrefix
{
    NSString *uniqname = [MPrintResponse lastUniqname];
    
    if (uniqname.length < 2)
        return nil;
    
    unichar c1 = [uniqname characterAtIndex:0];
    unichar c2 = [uniqname characterAtIndex:1];
    
    return [NSString stringWithFormat:@"/afs/umich.edu/user/%C/%C/%@", c1, c2, uniqname];
}

#pragma mark - Service Methods

-(NSString *)printRequestPathForFile:(ServiceFile *)file
{
    NSString *prefix = [self afsPrefix];
    
    NSString *path = [file fullpath];
    if ([path hasPrefix:@"/"])
        return [prefix stringByAppendingString:path];
    return [NSString stringWithFormat:@"%@/%@", prefix, path];
}

#pragma mark - MPrintNetworkedService Methods

-(NSString *)preparePathForDirectory:(NSString *)directory
{
    if (!directory)
        return @"";
    
    NSString *prefix = [self afsPrefix];
    if ([directory hasPrefix:@"/"])
        return [prefix stringByAppendingString:directory];
    return [NSString stringWithFormat:@"%@/%@", prefix, directory];
}

-(void)willPerformRequest:(MPrintRequest *)request
{
    // The dictionaries will need to be mutable so we can remove the AFS prefix.
    request.useMutableContainers = YES;
}

-(void)didReceiveResponse:(MPrintResponse *)response
{
    _prefix = [self afsPrefix];
}

-(ServiceFile *)fileFromJSONDictionary:(NSDictionary *)dictionary
{
    // We're allowed to do this since we set the request to generate mutable containers.
    NSMutableDictionary *dict = (id)dictionary;
    
    __weak NSString *path = dict[@"path"];
    if ([path hasPrefix:_prefix])
        dict[@"path"] = [path substringFromIndex:_prefix.length];
    return [super fileFromJSONDictionary:dictionary];
}

@end
