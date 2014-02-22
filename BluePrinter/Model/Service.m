//
//  Service.m
//  BluePrinter
//
//  Created by David Quesada on 1/29/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "Service.h"
#import "MPrintResponse.h"
#import "MPrintLocalService.h"
#import "MPrintDropboxService.h"
#import "MPrintDriveService.h"
#import "MPrintIFSService.h"
#import "MPrintLockerService.h"
#import "MPrintBoxService.h"

NSString * const MPrintDidRefreshServicesNotification = @"MPrintDidRefreshServicesNotification";

// Currently, services which implement file imports are responsible for posting this notification themselves.
NSString * const MPrintDidImportFileNotification = @"MPrintDidImportFileNotification";

NSDictionary *typedServices;
NSArray *allServices;

@interface Service ()
@property (readwrite) NSString *description;
@property (readwrite) int connectedStatus;
@property (readwrite) NSString *name;
@property (readwrite) ServiceType type;

@property MPrintLocalService *localService;

-(instancetype)initWithServiceType:(ServiceType)type;
-(void)updateStatus:(NSDictionary *)status;

+(MPrintLocalService *)loadLocalService;

@end

@implementation Service

+(ServiceType)serviceTypeFromString:(NSString *)string
{
    static NSDictionary *dict = nil;
    if (!dict) dict = @{
                        @"ifs" : @(ServiceTypeIFS),
                        @"locker" : @(ServiceTypeLocker),
                        @"drive" : @(ServiceTypeDrive),
                        @"dropbox" : @(ServiceTypeDropbox),
                        @"box" : @(ServiceTypeBox),
                        };
    return (ServiceType)[dict[string] integerValue];
}

+(instancetype)serviceWithType:(ServiceType)type
{
    return typedServices[@(type)];
}

+(instancetype)localService
{
    return [self loadLocalService];
}

+(MPrintLocalService *)loadLocalService
{
    static MPrintLocalService *local = nil;
    if (!local)
        local = [[MPrintLocalService alloc] init];
    return local;
}

+(NSArray *)allServices
{
    return allServices;
}

+(void)load
{
    Service *local, *ifs, *locker, *dropbox, *drive, *box;
    
    allServices = @[
                    local =     [self localService],
                    ifs =       [[Service alloc] initWithServiceType:ServiceTypeIFS],
                    locker =    [[Service alloc] initWithServiceType:ServiceTypeLocker],
                    dropbox =   [[Service alloc] initWithServiceType:ServiceTypeDropbox],
                    drive =     [[Service alloc] initWithServiceType:ServiceTypeDrive],
                    box =       [[Service alloc] initWithServiceType:ServiceTypeBox],
                    ];
    
    typedServices = @{
                      @(ServiceTypeLocal) : local,
                      @(ServiceTypeIFS) : ifs,
                      @(ServiceTypeLocker) : locker,
                      @(ServiceTypeDropbox) : dropbox,
                      @(ServiceTypeDrive) : drive,
                      @(ServiceTypeBox) : box,
                      };
}

+(void)refreshServices:(MPrintFetchHandler)completion
{
    [self fetchWithCompletion:^(NSMutableArray *objects, MPrintResponse *response) {
        if (response.success)
        {
            for (NSDictionary *dict in response.results)
            {
                ServiceType type = [self serviceTypeFromString:dict[@"name"]];
                Service *svc = typedServices[@(type)];
                [svc updateStatus:dict];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:MPrintDidRefreshServicesNotification object:nil];
        }
        
        if (completion)
            completion(nil, response);
    }];
}

+(NSString *)fetchAPIEndpoint
{
    return @"/services";
}

-(instancetype)initWithServiceType:(ServiceType)type
{
    if ((self = [self init]))
    {
        self.type = type;
        switch (type) {
            case ServiceTypeBox:
                return [[MPrintBoxService alloc] init];
            case ServiceTypeDrive:
                return [[MPrintDriveService alloc] init];
            case ServiceTypeDropbox:
                return [[MPrintDropboxService alloc] init];
            case ServiceTypeIFS:
                return [[MPrintIFSService alloc] init];
            case ServiceTypeLocker:
                return [[MPrintLockerService alloc] init];
            case ServiceTypeLocal:
                return [[MPrintLocalService alloc] init];
            default:
                NSLog(@"Unrecognized ServiceType: %d", (int)type);
                return nil;
        }
    }
    return self;
}

-(BOOL)isConnected
{
    return self.connectedStatus != 0;
}

-(void)updateStatus:(NSDictionary *)status
{
    self.connectedStatus = [status[@"is_connected"] intValue];
    self.name = status[@"name"];
    self.description = status[@"description"];
}

#pragma mark - Service Support Stubs

-(BOOL)supportsDownload
{
    return NO;
}

-(BOOL)supportsDelete
{
    return NO;
}

-(BOOL)supportsImport
{
    return NO;
}

-(BOOL)supportsRename
{
    return NO;
}

#pragma mark - Fetching Stuff

-(void)fetchDirectoryInfoForPath:(NSString *)path completion:(MPrintFetchHandler)completion
{
    
}

-(void)downloadFileWithName:(NSString *)filename inPath:(NSString *)path completion:(MPrintDataHandler)completion
{
    @throw @"Downloading service files is currently not supported.";
}

#pragma mark - Service Stubs

-(ServiceError)importFileAtLocalPath:(NSString *)path
{
    return ServiceErrorNotSupported;
}

-(void)deleteFileAtPath:(NSString *)path completion:(void (^)(ServiceError))completion
{
    if (completion)
        completion(ServiceErrorNotSupported);
}

-(ServiceError)renameFileAtPath:(NSString *)path toNewPath:(NSString *)newPath
{
    return ServiceErrorNotSupported;
}

@end
