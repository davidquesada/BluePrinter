//
//  ServiceFile.h
//  BluePrinterCore
//
//  Created by David Quesada on 1/31/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Service.h"

@interface ServiceFile : NSObject

@property (readonly) ServiceType serviceType;
@property (readonly) BOOL isDirectory;
@property (readonly) NSString *name;
@property (readonly) NSString *path;
@property (readonly) NSString *extension;
@property (readonly) BOOL isDownloadable;
@property (readonly) BOOL isDeletable;
@property (readonly) Service *service;

// Returns, if known, the exact path where this file resides.
// For networked files, obviously this will be nil.
// This will also be nil for files created with the constructor initWithPath:rootPath.
// This will only be non-nil for files created with the constructor initWithFileAtPath:.
@property (readonly) NSString *physicalLocalPath;

@property (readonly) NSString *fullpath;
// Defaults to self.fullpath.
@property (readonly) NSString *pathForPrintRequest;
@property (readonly) NSDate *modifiedDate;

-(id)initWithJSONDictionary:(NSDictionary *)dict service:(Service *)service;

// These two constructors create local files. The first is used to create ServiceFiles representing
// files stored in the "sandbox" of the MPrintLocalService class. The second can be used to wrap a file
// existing anywhere on the file system.
-(id)initWithPath:(NSString *)path rootPath:(NSString *)base;
-(id)initWithFileAtPath:(NSString *)filepath;

-(void)fetchDirectoryContentsWithCompletion:(MPrintFetchHandler)completion;
-(void)downloadFileContentsWithCompletion:(MPrintDataHandler)completion;
-(NSData *)downloadFileContentsBlocking:(MPrintResponse **)response;

-(void)deleteWithCompletion:(void (^)(BOOL wasDeleted))completion;
-(BOOL)deleteBlocking;

@end
