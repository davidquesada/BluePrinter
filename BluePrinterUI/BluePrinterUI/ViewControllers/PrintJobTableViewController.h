//
//  PrintJobTableViewController.h
//  BluePrinterUI
//
//  Created by David Quesada on 2/15/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BluePrinterBaseViewControllers.h"

@class PrintRequest;
@class PrintJobTableViewController;

@protocol PrintJobTableViewControllerDelegate <NSObject>
@optional
-(void)viewControllerWillDismiss:(PrintJobTableViewController *)controller;

// Delegates can implement this method to dismiss the view controller in a customized way.
-(void)dismissPrintJobViewController:(PrintJobTableViewController *)controller;

@end

@interface PrintJobTableViewController : BluePrinterUITableViewController

+(UINavigationController *)presentableViewControllerWithPrintRequest:(PrintRequest *)request delegate:(id<PrintJobTableViewControllerDelegate>)delegate;
-(id)initWithPrintRequest:(PrintRequest *)request;

@property(readonly) PrintRequest *request;
@property(weak) id<PrintJobTableViewControllerDelegate> delegate;

@end
