//
//  Service.h
//  BluePrinter
//
//  Created by David Quesada on 1/29/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MPrintObject.h"

typedef NS_ENUM(NSInteger, ServiceType)
{
    ServiceTypeNone,
    ServiceTypeIFS,
    ServiceTypeLocker,
    ServiceTypeDropbox,
    ServiceTypeDrive,
    ServiceTypeBox,
    
    // A wrapper around the local filesystem.
    ServiceTypeLocal,
};

typedef NS_ENUM(NSInteger, ServiceError)
{
    // No error.
    ServiceErrorNone,
    
    // Generic failure case.
    ServiceErrorFailure,
    
    // The specified operation is not supported for this service.
    ServiceErrorNotSupported,
    
    // Attempted to rename/save/import a file to a path that already exists.
    ServiceErrorFileExists,
};

extern NSString * const MPrintDidRefreshServicesNotification;

// The notification object will be a ServiceFile, if the service is able to generate one
// on import. Otherwise, the notification object will be nil.
extern NSString * const MPrintDidImportFileNotification;

@class ServiceFile;

@interface Service : MPrintObject

+(void)refreshServices:(MPrintFetchHandler)completion;

+(ServiceType)serviceTypeFromString:(NSString *)string;
+(instancetype)serviceWithType:(ServiceType)type;

+(instancetype)localService;

+(NSArray *)allServices;

@property (readonly) NSString *description;
@property (readonly) BOOL isConnected;
@property (readonly) NSString *name;
@property (readonly) ServiceType type;
@property (readonly) BOOL supportsDownload;
@property (readonly) BOOL supportsDelete;
@property (readonly) BOOL supportsImport;
@property (readonly) BOOL supportsRename;

@property (readonly) BOOL supportsDisconnect;
-(void)connect:(void (^)())completion;
-(void)disconnect:(void (^)())completion;
-(void)invalidateConnection;

// The 'objects' property of the completion is an array of ServiceFile objects.
-(void)fetchDirectoryInfoForPath:(NSString *)path completion:(MPrintFetchHandler)completion;
-(void)downloadFileWithName:(NSString *)filename inPath:(NSString *)path completion:(MPrintDataHandler)completion;

#pragma mark - File Manipulation Methods

-(ServiceError)importFileAtLocalPath:(NSString *)path;
-(void)deleteFileAtPath:(NSString *)path completion:(void (^)(ServiceError error))completion;
-(ServiceError)renameFileAtPath:(NSString *)path toNewPath:(NSString *)newPath;

// A value to be attached to a 'filepath' key of a URL request.
// By default, returns the 'fullpath' property of the file.
-(NSString *)printRequestPathForFile:(ServiceFile *)file;

@end
