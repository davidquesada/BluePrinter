//
//  MPrintLocalService.m
//  BluePrinter
//
//  Created by David Quesada on 2/11/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MPrintLocalService.h"
#import "ServiceFile.h"
#import "MPrintResponse.h"

@interface MPrintLocalService()
{
    NSString *_directory;
}
@end

@implementation MPrintLocalService

- (id)init
{
    self = [super init];
    if (self) {
        _directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask, YES) lastObject];
        _directory = [_directory stringByAppendingPathComponent:@"LocalFiles"];
        [[NSFileManager defaultManager] createDirectoryAtPath:_directory withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return self;
}

#pragma mark - Basic service information.

-(NSString *)description
{
    return @"Saved Files";
}

-(BOOL)isConnected
{
    return YES;
}

-(NSString *)name
{
    return @"local";
}

-(ServiceType)type
{
    return ServiceTypeLocal;
}

-(BOOL)supportsDownload
{
    return YES;
}

-(BOOL)supportsDelete
{
    return YES;
}

-(BOOL)supportsImport
{
    return YES;
}

-(BOOL)supportsRename
{
    return YES;
}

#pragma mark - Directory/File Methods

-(void)fetchDirectoryInfoForPath:(NSString *)path completion:(MPrintFetchHandler)completion
{
    NSMutableArray *files = [NSMutableArray new];
    
    // TODO: Should we bother supporting subdirectories for the local service?
    path = _directory;
    NSFileManager *manager = [NSFileManager defaultManager];
    for (NSString *filename in [manager contentsOfDirectoryAtPath:path error:nil])
    {
        NSString *fullpath = [path stringByAppendingPathComponent:filename];
        ServiceFile *file = [[ServiceFile alloc] initWithLocalPath:fullpath];
        if (file)
            [files addObject:file];
    }
    if (completion)
        completion(files, [MPrintResponse successResponse]);
}

-(void)downloadFileWithName:(NSString *)filename inPath:(NSString *)path completion:(MPrintDataHandler)completion
{
    path = _directory;
    NSString *fullpath = [path stringByAppendingPathComponent:filename];
    NSData *data = [NSData dataWithContentsOfFile:fullpath];
    if (completion)
        completion(data, [MPrintResponse successResponse]);
}

#pragma - File Manipulation Methods

-(ServiceError)importFileAtLocalPath:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![path length] || ![manager fileExistsAtPath:path])
        return ServiceErrorFailure;
    
    NSString *destination = [_directory stringByAppendingPathComponent:[path lastPathComponent]];
    if ([manager fileExistsAtPath:destination])
        return ServiceErrorFileExists;
    
    NSError *err = nil;
    BOOL r = [manager copyItemAtPath:path toPath:destination error:&err];
    
    if (!r || err)
    {
        NSLog(@"Error importing file to local service: %@", err);
        return ServiceErrorFailure;
    }

    return ServiceErrorNone;
}

-(void)deleteFileAtPath:(NSString *)path completion:(void (^)(ServiceError))completion
{
    NSFileManager *fileman = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL result = [fileman removeItemAtPath:path error:&error];
    if (!result)
        NSLog(@"Unable to delete file from MPrintLocalService: %@", error);
    
    if (completion)
        completion(result ? ServiceErrorNone : ServiceErrorFailure);
}

-(ServiceError)renameFileAtPath:(NSString *)path toNewPath:(NSString *)newPath
{
    return ServiceErrorFailure;
}

@end
