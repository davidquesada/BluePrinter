//
//  MPrintServiceAuthenticationViewController.m
//  BluePrinter
//
//  Created by David Quesada on 2/22/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MPrintServiceAuthenticationViewController.h"
#import "MPrintNetworkedService.h"


@interface MPrintServiceAuthenticationViewController ()<UIWebViewDelegate>
{
    BOOL _authd;
    MPrintNetworkedService *_service;
    UIWebView *webView;
    NSURL *_url;
    BOOL _hasAppeared;
}
-(void)dismiss:(id)sender;
@end

@implementation MPrintServiceAuthenticationViewController

-(id)initWithURL:(NSURL *)url service:(MPrintNetworkedService *)service
{
    UIWebView *web = [[UIWebView alloc] initWithFrame:CGRectZero];
    UIViewController *root = [[UIViewController alloc] init];
    root.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];
    root.navigationItem.title = @"Authentication";
    root.view = web;
    
    
    if ((self = [self initWithRootViewController:root]))
    {
        self.navigationBar.translucent = NO;
        web.delegate = self;
        _service = service;
        webView = web;
        _url = url;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_hasAppeared)
        return;
    _hasAppeared = YES;
    [webView loadRequest:[NSURLRequest requestWithURL:_url]];
}

-(void)dismiss:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(authenticationController:willDismissWithAuthenticationStatus:)])
        [self.delegate authenticationController:self willDismissWithAuthenticationStatus:_authd];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate Methods

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    NSLog(@"AUTHURL: %@", url);
    if ([url.host isEqualToString:@"mprint.umich.edu"])
    {
        _authd = YES;
        [self dismiss:nil];
        return YES;
    }
    return YES;
}

@end
