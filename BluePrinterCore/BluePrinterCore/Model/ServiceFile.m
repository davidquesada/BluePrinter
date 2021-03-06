//
//  ServiceFile.m
//  BluePrinterCore
//
//  Created by David Quesada on 1/31/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "ServiceFile.h"

@interface ServiceFile ()
{
    Service *_service;
    NSInteger _modifiedTimestamp;
    NSDate *_cachedModifiedDate;
    NSString *_physicalLocalPath;
}
@property (readwrite) ServiceType serviceType;
@property (readwrite) BOOL isDirectory;
@property (readwrite) NSString *name;
@property (readwrite) NSString *path;
@property (readwrite) NSString *extension;

@end

@implementation ServiceFile

-(id)initWithFileAtPath:(NSString *)filepath
{
    self = [self initWithPath:filepath rootPath:nil];
    if (self)
    {
        _physicalLocalPath = filepath;
    }
    return self;
}

-(id)initWithPath:(NSString *)path rootPath:(NSString *)base
{
    if ((self = [self init]))
    {
        self.serviceType = ServiceTypeLocal;
        self.name = [path lastPathComponent];
        self.path = [path stringByDeletingLastPathComponent];
        self.extension = [_name pathExtension];
        
        NSString *entirePath = path;
        if (base.length)
            entirePath = [base stringByAppendingPathComponent:path];
        
        BOOL exists, isdir;
        exists = [[NSFileManager defaultManager] fileExistsAtPath:entirePath isDirectory:&isdir];
        if (!exists)
        {
            NSLog(@"Invalid entirePath for local ServiceFile: %@", entirePath);
            return nil;
        }
        _cachedModifiedDate = [[NSFileManager defaultManager] attributesOfItemAtPath:entirePath error:nil].fileModificationDate;
        self.isDirectory = isdir;
    }
    return self;
}

-(id)initWithJSONDictionary:(NSDictionary *)dict service:(Service *)service
{
    if ((self = [self init]))
    {
        _service = service;
        _name = dict[@"name"];
        _path = dict[@"path"];
        _isDirectory = [dict[@"type"] isEqualToString:@"dir"];
        _extension = dict[@"extension"];
        _modifiedTimestamp = [dict[@"modified"] integerValue];
    }
    return self;
}

-(BOOL)isDownloadable
{
    return self.service.supportsDownload;
}

-(BOOL)isDeletable
{
    return !_isDirectory && self.service.supportsDelete;
}

-(Service *)service
{
    if (_service)
        return _service;
    return _service = [Service serviceWithType:self.serviceType];
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

-(NSString *)physicalLocalPath
{
    // This may be nil, if the file is a network file or was a local file created
    // without specifying the full path;
    return _physicalLocalPath;
}

-(NSString *)pathForPrintRequest
{
    return [self.service printRequestPathForFile:self];
}

-(NSDate *)modifiedDate
{
    if (_cachedModifiedDate)
        return _cachedModifiedDate;
    if (_modifiedTimestamp)
        return [NSDate dateWithTimeIntervalSince1970:_modifiedTimestamp];
    return nil;
}

-(void)fetchDirectoryContentsWithCompletion:(MPrintFetchHandler)completion
{
    [self.service fetchDirectoryInfoForPath:self.fullpath completion:completion];
}

-(void)downloadFileContentsWithCompletion:(MPrintDataHandler)completion
{
    [self.service downloadFile:self completion:completion];
}

-(void)deleteWithCompletion:(void (^)(BOOL))completion
{
    [self.service deleteFileAtPath:self.fullpath completion:^(ServiceError error) {
        if (completion)
            completion(error == ServiceErrorNone);
    }];
}

-(BOOL)deleteBlocking
{
    if (!self.service)
        return NO;
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    __block BOOL ret = NO;
    [NSThread sleepForTimeInterval:.2];
    [self deleteWithCompletion:^(BOOL wasDeleted) {
        ret = wasDeleted;
        dispatch_semaphore_signal(sema);
    }];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    return ret;
}

-(NSData *)downloadFileContentsBlocking:(MPrintResponse *__autoreleasing *)response
{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    __block NSData *ret = nil;
    
    NSDebugLog(@"Waiting for blocking file download...");
    [self downloadFileContentsWithCompletion:^(NSData *data, MPrintResponse *actualResponse) {
        
        ret = data;
        if (response)
            *response = actualResponse;
        
        dispatch_semaphore_signal(sema);
    }];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    return ret;
}

@end
