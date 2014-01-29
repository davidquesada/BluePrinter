//
//  LoginViewController.m
//  BluePrinter
//
//  Created by David Quesada on 1/17/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)init
{
    self = [super init];
    if (self) {
        
        UIWebView *view = [[UIWebView alloc] initWithFrame:CGRectZero];
        UIViewController *root = [[UIViewController alloc] init];
        root.view = view;
        
        root.navigationItem.title = @"LoginPage";
        root.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissWebView:)];
        
        self.viewControllers = @[ root ];
        
        
        [view loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://weblogin.umich.edu"]]];
        
    }
    return self;
}

-(IBAction)dismissWebView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
