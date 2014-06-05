//
//  BaseViewController.m
//  BluePrinterUI
//
//  Created by David Quesada on 3/12/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "BluePrinterBaseViewControllers.h"

@interface BluePrinterUIViewController ()
{
    NSIndexPath *_selectedIndexPath;
}
-(UITableView *)tableView;
@end

@implementation BluePrinterUIViewController

-(UITableView *)tableView
{
    return nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.actuallyDeselectRowOnViewWillAppear)
        [[self tableView] deselectRowAtIndexPath:_selectedIndexPath animated:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _selectedIndexPath = nil;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.actuallyDeselectRowOnViewWillAppear)
        [[self tableView] selectRowAtIndexPath:_selectedIndexPath animated:animated scrollPosition:UITableViewScrollPositionNone];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndexPath = indexPath;
}

@end


@interface BluePrinterUITableViewController ()
{
    NSIndexPath *_selectedIndexPath;
}
@end

@implementation BluePrinterUITableViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.actuallyDeselectRowOnViewWillAppear)
        [[self tableView] deselectRowAtIndexPath:_selectedIndexPath animated:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _selectedIndexPath = nil;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.actuallyDeselectRowOnViewWillAppear)
        [[self tableView] selectRowAtIndexPath:_selectedIndexPath animated:animated scrollPosition:UITableViewScrollPositionNone];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndexPath = indexPath;
}

@end
