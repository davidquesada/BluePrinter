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
};

@interface Service : MPrintObject

+(ServiceType)serviceTypeFromString:(NSString *)string;
+(instancetype)serviceWithType:(ServiceType)type;

@property (readonly) NSString *description;
@property (readonly) BOOL isConnected;
@property (readonly) NSString *name;
@property (readonly) ServiceType type;
@property (readonly) BOOL supportsDownload;

-(void)fetchDirectoryInfoForPath:(NSString *)path completion:(MPrintFetchHandler)completion;
-(void)downloadFileWithName:(NSString *)filename inPath:(NSString *)path completion:(MPrintDataHandler)completion;

@end
