//
//  Account.m
//  BluePrinter
//
//  Created by David Quesada on 1/16/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "Account.h"
#import "Service.h"
#import "PrintJob.h"
#import "MPrintRequest.h"
#import "MPrintResponse.h"
#import "MPrintCosignManager.h"

@interface Account ()
@property(readwrite) NSString *username;
+(MPrintRequest *)requestForUserInfo;
@end

@implementation Account

+(Account *)main
{
    static Account *m = nil;
    if (m)
        return m;
    return m = [[Account alloc] init];
}

+(MPrintRequest *)requestForUserInfo
{
    MPrintRequest *req = [[MPrintRequest alloc] initWithEndpoint:@"/users"];
    return req;
}

+(BOOL)parseLoginStatusResponse:(MPrintResponse *)response
{
    if (!response.jsonObject)
        return NO;
    NSString *uniqname = response.jsonObject[@"uniqname"];
    if (!uniqname)
        return NO;
    
    Account *main = [Account main];
    main.username = uniqname;
    return YES;
}

+(void)checkLoginStatus:(void (^)(BOOL))completion
{
    MPrintRequest *req = [self requestForUserInfo];
    [req performWithCompletion:^(MPrintResponse *response) {
        
        BOOL r = [self parseLoginStatusResponse:response];
        if (completion)
            completion(r);
    }];
}

+(void)logout:(void (^)(BOOL))completion
{
    MPrintRequest *request = [[MPrintRequest alloc] initWithCustomURL:[NSURL URLWithString:@"https://weblogin.umich.edu/cosign-bin/logout"] method:POST];
    
    [request.urlRequest setHTTPBody:[@"url=https%3A%2F%2Fweblogin.umich.edu%2F&verify=Log+Out" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request performWithCompletion:^(MPrintResponse *response) {
        
        for (Service *svc in [Service allServices])
            [svc invalidateConnection];
        
        // TODO: How do we verify the success of a logout?
        if (completion)
            completion(YES);
    }];
    
    [PrintJob removeUserJobs];
    [MPrintCosignManager userDidLogOut];
}

@end
