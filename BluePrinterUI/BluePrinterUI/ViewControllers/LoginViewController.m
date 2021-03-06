//
//  LoginViewController.m
//  BluePrinterUI
//
//  Created by David Quesada on 1/17/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()<UIWebViewDelegate>
{
    BOOL _didLogIn;
}
@end

@implementation LoginViewController

- (id)init
{
    self = [super init];
    if (self) {
        
        UIWebView *view = [[UIWebView alloc] initWithFrame:CGRectZero];
        UIViewController *root = [[UIViewController alloc] init];
        root.view = view;
        
        root.navigationItem.title = @"Login";
        root.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissWebView:)];
        
        self.viewControllers = @[ root ];
        
        [view loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://weblogin.umich.edu/?cosign-mprint&https://mprint.umich.edu/api"]]];
        view.delegate = self;
        
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        self.navigationBar.translucent = NO;
    }
    return self;
}

-(IBAction)dismissWebView:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(loginViewController:willDismissWithLoginResult:)])
        [self.delegate loginViewController:self willDismissWithLoginResult:_didLogIn];
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(loginViewController:didDismissWithLoginResult:)])
            [self.delegate loginViewController:self didDismissWithLoginResult:_didLogIn];
    }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - UIWebViewDelegate Methods

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *location = request.URL.description;

    // If we are redirected to the mprint API page, then the login must have been successful.
    if ([location isEqualToString:@"https://mprint.umich.edu/api"])
    {
        [MPrintCosignManager userDidLogIn];
        _didLogIn = YES;
        [self dismissWebView:nil];
        return NO;
    }
    
    return YES;
}

@end
