//
//  BluePrinterBaseViewControllers.h
//  BluePrinterUI
//
//  Created by David Quesada on 3/12/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BluePrinterUIViewController : UIViewController

@property BOOL actuallyDeselectRowOnViewWillAppear;

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface BluePrinterUITableViewController : UITableViewController

@property BOOL actuallyDeselectRowOnViewWillAppear;

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
