//
//  Service.m
//  BluePrinter
//
//  Created by David Quesada on 1/29/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "Service.h"
#import "MPrintResponse.h"

NSMutableDictionary *savedServices;

@interface Service ()
@property (readwrite) NSString *description;
@property (readwrite) int connectedStatus;
@property (readwrite) NSString *name;
@property (readwrite) ServiceType type;

-(instancetype)initWithServiceType:(ServiceType)type;
+(void)clearSavedServices;

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

+(void)clearSavedServices
{
    if (savedServices)
        [savedServices removeAllObjects];
    else
        savedServices = [NSMutableDictionary new];
}

+(instancetype)serviceWithType:(ServiceType)type
{
    return savedServices[@(type)];
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
    }
    return self;
}

-(BOOL)isConnected
{
    return self.connectedStatus != 0;
}

-(BOOL)supportsDownload
{
    return NO;
}

+(NSDictionary *)fieldConversions
{
    return @{
             @"description" : @"description",
             @"is_connected" : @"connectedStatus",
             @"name" : @"name",
             };
}

-(void)fetchDirectoryInfoForPath:(NSString *)path completion:(MPrintFetchHandler)completion
{
    
}

-(void)downloadFileWithName:(NSString *)filename inPath:(NSString *)path completion:(MPrintDataHandler)completion
{
    @throw @"Downloading service files is currently not supported.";
}

-(instancetype)initWithJSONDictionary:(NSDictionary *)dictionary
{
    NSString *type = dictionary[@"name"];
    if (!type)
        return nil;
    ServiceType realtype = [Service serviceTypeFromString:type];
    if (realtype == ServiceTypeNone)
        return nil;
    if ((self = [self initWithServiceType:realtype]))
    {
        if (!savedServices)
            savedServices = [NSMutableDictionary new];
        savedServices[@(realtype)] = self;
    }
    return self;
}

@end
