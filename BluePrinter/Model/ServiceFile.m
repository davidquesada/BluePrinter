//
//  ServiceFile.m
//  BluePrinter
//
//  Created by David Quesada on 1/31/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "ServiceFile.h"

@interface ServiceFile ()
{
    Service *_service;
}
@property (readwrite) ServiceType serviceType;
@property (readwrite) BOOL isDirectory;
@property (readwrite) NSString *name;
@property (readwrite) NSString *path;
@end

@implementation ServiceFile

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

-(id)initWithLocalPath:(NSString *)path
{
    if ((self = [self init]))
    {
        self.serviceType = ServiceTypeLocal;
        self.name = [path lastPathComponent];
        self.path = [path stringByDeletingLastPathComponent];
        
        BOOL exists, isdir;
        exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isdir];
        if (!exists)
        {
            NSLog(@"Invalid path for local ServiceFile: %@", path);
            return nil;
        }
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
    }
    return self;
}

-(BOOL)isDownloadable
{
    return self.service.supportsDownload;
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

-(void)fetchDirectoryContentsWithCompletion:(MPrintFetchHandler)completion
{
    [self.service fetchDirectoryInfoForPath:self.fullpath completion:completion];
}

-(void)downloadFileContentsWithCompletion:(MPrintDataHandler)completion
{
    [self.service downloadFileWithName:self.name inPath:self.path completion:completion];
}

-(NSData *)downloadFileContentsBlocking:(MPrintResponse *__autoreleasing *)response
{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    __block NSData *ret = nil;
    
    NSLog(@"Waiting for blocking file download...");
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
