//
//  ServiceFile.m
//  BluePrinter
//
//  Created by David Quesada on 1/31/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "ServiceFile.h"

@interface ServiceFile ()
@property (readwrite) ServiceType serviceType;
@property (readwrite) BOOL isDirectory;
@property (readwrite) NSString *name;
@property (readwrite) NSString *path;
@end

@implementation ServiceFile

-(BOOL)isDownloadable
{
    return self.service.supportsDownload;
}

-(Service *)service
{
    return [Service serviceWithType:self.serviceType];
}

-(NSString *)fullpath
{
    NSString *name = self.name;
    NSString *path = self.path;
    if (!name)
        return path;
    if (!path)
        return name;
    return [path stringByAppendingPathComponent:name];
}

-(void)fetchDirectoryContentsWithCompletion:(MPrintFetchHandler)completion
{
    [self.service fetchDirectoryInfoForPath:self.fullpath completion:completion];
}

-(void)downloadFileContentsWithCompletion:(MPrintDataHandler)completion
{
    [self.service downloadFileWithName:self.name inPath:self.path completion:completion];
}

@end
