//
//  BaseViewController.m
//  BluePrinter
//
//  Created by David Quesada on 3/12/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()
{
    NSIndexPath *_selectedIndexPath;
}
-(UITableView *)tableView;
@end

@implementation BaseViewController

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


@interface BaseTableViewController ()
{
    NSIndexPath *_selectedIndexPath;
}
@end

@implementation BaseTableViewController

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
