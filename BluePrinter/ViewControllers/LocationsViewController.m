//
//  LocationsViewController.m
//  BluePrinter
//
//  Created by David Paul Quesada on 1/14/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "LocationsViewController.h"
#import "Location.h"

@interface LocationsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak) IBOutlet UITableView *tableView;
@end

@implementation LocationsViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    UIRefreshControl *c = [[UIRefreshControl alloc] initWithFrame:CGRectZero];
    [self.tableView addSubview:c];
    [c addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UINavigationBar *bar = self.navigationController.navigationBar;
    bar.clipsToBounds = NO;
    bar = (id)[bar.subviews objectAtIndex:1];
    bar.frame = CGRectMake(0, 0, 320, 80);
}

-(void)refresh:(UIRefreshControl *)sender
{
    [Location refreshLocations:^(BOOL success) {
        [sender endRefreshing];
    }];
}

#pragma mark - UITableViewDelegate/DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [Location locationCount];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NO"];
    
    cell.textLabel.text = [cell description];
    return cell;
}

@end
