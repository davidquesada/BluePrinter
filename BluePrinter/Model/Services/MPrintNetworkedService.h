//
//  MPrintNetworkedService.h
//  BluePrinter
//
//  Created by dquesada on 2/20/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "Service.h"

@class MPrintRequest;
@class MPrintResponse;
@class ServiceFile;

typedef NS_ENUM(NSInteger, MPrintNetworkedServiceConnectionMethod)
{
    MPrintNetworkedServiceConnectionMethodNone,
    MPrintNetworkedServiceConnectionMethodSimple,
    MPrintNetworkedServiceConnectionMethodAuthenticated,
};

typedef NS_ENUM(NSInteger, MPrintNetworkedServiceAuthResult)
{
    MPrintNetworkedServiceAuthResultNone,
    MPrintNetworkedServiceAuthResultApproved,
    MPrintNetworkedServiceAuthResultDenied,
};

@interface MPrintNetworkedService : Service

@property(readonly) MPrintNetworkedServiceConnectionMethod connectionMethod;

-(NSString *)preparePathForDirectory:(NSString *)directory;
-(void)willPerformRequest:(MPrintRequest *)request;
-(void)didReceiveResponse:(MPrintResponse *)response;
-(ServiceFile *)fileFromJSONDictionary:(NSDictionary *)dict;

-(MPrintRequest *)requestForSimpleConnect;

-(NSURL *)authorizationURL;
-(MPrintNetworkedServiceAuthResult)actionForIntermediateURL:(NSURL *)url;
-(MPrintNetworkedServiceAuthResult)actionForMPrintURL:(NSURL *)url;

@end
