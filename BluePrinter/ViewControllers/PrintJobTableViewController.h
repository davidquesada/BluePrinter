//
//  PrintJobTableViewController.h
//  BluePrinter
//
//  Created by David Quesada on 2/15/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PrintRequest;

@interface PrintJobTableViewController : UITableViewController

-(id)initWithPrintRequest:(PrintRequest *)request;

@property(readonly) PrintRequest *request;

@end
