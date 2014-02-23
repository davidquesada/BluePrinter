//
//  MPrintNetworkedService.m
//  BluePrinter
//
//  Created by dquesada on 2/20/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MPrintNetworkedService.h"
#import "MPrintRequest.h"
#import "MPrintResponse.h"
#import "ServiceFile.h"
#import "MPrintServiceAuthenticationViewController.h"

@interface MPrintNetworkedService ()<MPrintServiceAuthenticationViewControllerDelegate>

@property(copy) void(^completionHandler)();

-(NSURL *)urlForDirectoryAtPath:(NSString *)path;

-(NSURL *)serviceURL;
-(NSURL *)urlForDisconnect;
-(NSURL *)urlForConnect;

-(void)doSimpleConnect:(void (^)())completion;
-(void)doAuthenticatedConnect:(void (^)())completion;

-(UIViewController *)targetViewController;
-(void)getAuthenticationURL:(void (^)(NSURL *url))completion;

@end

@implementation MPrintNetworkedService

-(NSString *)preparePathForDirectory:(NSString *)directory
{
    return directory;
}

-(NSURL *)urlForDirectoryAtPath:(NSString *)path
{
    path = [self preparePathForDirectory:path];
    
    // TODO: I'm not sure if this is the right method to encode the path.
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *url = [NSString stringWithFormat:@"https://mprint.umich.edu/api/services/%@?ls&path=%@", [self name], path];
    return [NSURL URLWithString:url];
}

-(ServiceFile *)fileFromJSONDictionary:(NSDictionary *)dict
{
    return [[ServiceFile alloc] initWithJSONDictionary:dict service:self];
}

-(void)willPerformRequest:(MPrintRequest *)request
{
}

-(void)didReceiveResponse:(MPrintResponse *)response
{
}

-(NSURL *)serviceURL
{
    NSString *url = [NSString stringWithFormat:@"https://mprint.umich.edu/api/services/%@", self.name];
    return [NSURL URLWithString:url];
}

-(NSURL *)urlForDisconnect
{
    return [self serviceURL];
}

-(NSURL *)urlForConnect
{
    return [self serviceURL];
}

-(MPrintNetworkedServiceConnectionMethod)connectionMethod
{
    return MPrintNetworkedServiceConnectionMethodNone;
}

#pragma mark - Service Methods

-(void)fetchDirectoryInfoForPath:(NSString *)path completion:(MPrintFetchHandler)completion
{
    NSURL *url = [self urlForDirectoryAtPath:path];
    MPrintRequest *req = [[MPrintRequest alloc] initWithCustomURL:url method:GET];
    [self willPerformRequest:req];
    
    [req performWithCompletion:^(MPrintResponse *response) {
        
        [self didReceiveResponse:response];
        NSMutableArray *files = nil;
        if (response.success)
        {
            files = [[NSMutableArray alloc] initWithCapacity:response.count];
            for (NSDictionary *dict in response.results)
            {
                ServiceFile *file = [self fileFromJSONDictionary:dict];
                [files addObject:file];
            }
        }
        
        if (completion)
            completion(files, response);
        
    }];
}

-(BOOL)supportsDisconnect
{
    return YES;
}

-(void)disconnect:(void (^)())completion
{
    MPrintRequest *req = [[MPrintRequest alloc] initWithCustomURL:[self urlForDisconnect] method:DELETE];

    [req performWithCompletion:^(MPrintResponse *response) {

        if (response.success)
            [self setValue:@(0) forKey:@"connectedStatus"];
        
        if (completion)
            completion();
        
    }];
}

-(void)connect:(void (^)())completion
{
    MPrintNetworkedServiceConnectionMethod method = [self connectionMethod];
    if (method == MPrintNetworkedServiceConnectionMethodSimple)
        [self doSimpleConnect:completion];
    else if (method == MPrintNetworkedServiceConnectionMethodAuthenticated)
        [self doAuthenticatedConnect:completion];
    else
    {
        NSLog(@"This Networked service doesn't support connection.");
        if (completion)
            completion();
    }
}

#pragma Connection related Methods

-(void)doSimpleConnect:(void (^)())completion
{
    MPrintRequest *req = [[MPrintRequest alloc] initWithCustomURL:[self urlForConnect] method:PUT];
    [req addBodyValue:@"" forKey:@"enable"];
    [req performWithCompletion:^(MPrintResponse *response) {

        if (response.success)
            [self setValue:@(1) forKey:@"connectedStatus"];
        
        if (completion)
            completion();
        
    }];
}

-(void)doAuthenticatedConnect:(void (^)())completion
{
    self.completionHandler = completion;
    [self getAuthenticationURL:^(NSURL *url) {
        
        if (!url)
        {
            if (completion)
                completion();
            return;
        }
        
        MPrintServiceAuthenticationViewController *controller = [[MPrintServiceAuthenticationViewController alloc] initWithURL:url service:self];
        controller.delegate = self;
        UIViewController *target = [self targetViewController];
        [target presentViewController:controller animated:YES completion:nil];
        
    }];
}

-(UIViewController *)targetViewController
{
    UIApplication *app = [UIApplication sharedApplication];
    UIWindow *window = app.keyWindow;
    return window.rootViewController;
}

// completion must be non-nil
-(void)getAuthenticationURL:(void (^)(NSURL *))completion
{
    NSURL *infourl = [self serviceURL];
    MPrintRequest *req = [[MPrintRequest alloc] initWithCustomURL:infourl method:GET];
    
    [req performWithCompletion:^(MPrintResponse *response) {
        
        NSURL *url = nil;
        
        if (!response.success || !response.count)
            completion(nil);
        
        NSString *str = response.results[0][@"authorization_url"];
        url = [NSURL URLWithString:str];
        
        completion(url);
    }];
}

#pragma mark - MPrintServiceAuthenticationViewControllerDelegate Methods

-(void)authenticationController:(MPrintServiceAuthenticationViewController *)controller willDismissWithAuthenticationStatus:(BOOL)authenticated
{
    if (authenticated)
        [self setValue:@(1) forKey:@"connectedStatus"];
    
    if (self.completionHandler)
        self.completionHandler();
}

@end
