//
//  JobsViewController.m
//  BluePrinter
//
//  Created by David Paul Quesada on 1/14/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "JobsViewController.h"
#import "Account.h"

@interface JobsViewController ()

@end

@implementation JobsViewController


-(IBAction)logout:(id)sender
{
    [Account logout:^(BOOL success) {
        NSLog(@"YO");
    }];
}

@end
