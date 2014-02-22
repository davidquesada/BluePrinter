//
//  ServiceFile.h
//  BluePrinter
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
@property (readonly) Service *service;
@property (readonly) NSString *fullpath;
@property (readonly) NSDate *modifiedDate;

-(id)initWithJSONDictionary:(NSDictionary *)dict service:(Service *)service;
-(id)initWithLocalPath:(NSString *)path;

-(void)fetchDirectoryContentsWithCompletion:(MPrintFetchHandler)completion;
-(void)downloadFileContentsWithCompletion:(MPrintDataHandler)completion;
-(NSData *)downloadFileContentsBlocking:(MPrintResponse **)response;

@end
