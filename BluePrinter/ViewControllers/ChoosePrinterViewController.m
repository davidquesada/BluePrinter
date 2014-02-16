//
//  ChoosePrinterViewController.m
//  BluePrinter
//
//  Created by David Quesada on 2/15/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "ChoosePrinterViewController.h"
#import "Location.h"

@interface ChoosePrinterViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation ChoosePrinterViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Printing Locations";
}

-(void)loadView
{
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.view = table;
    
    table.dataSource = self;
    table.delegate = self;
    
    table.rowHeight = 52;
}

-(void)refresh
{
    
}

#pragma mark - UITableView Stuff

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"yo"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"yo"];
    }
    
    Location *location = [Location locationAtIndex:indexPath.row];
    
    cell.textLabel.text = location.displayName;
    cell.detailTextLabel.text = location.location;
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [Location locationCount];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Location *loc = [Location locationAtIndex:indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(choosePrinterViewController:didChoosePrintLocation:)])
        [self.delegate choosePrinterViewController:self didChoosePrintLocation:loc];
}

@end
