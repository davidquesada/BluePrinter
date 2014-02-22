//
//  LocationsViewController.m
//  BluePrinter
//
//  Created by David Paul Quesada on 1/14/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "LocationsViewController.h"
#import "Location.h"
#import "Account.h"
#import "LoginViewController.h"

@interface LocationsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak) IBOutlet UITableView *tableView;

-(void)didRefreshLocations:(NSNotification *)note;

@end

@implementation LocationsViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    UIRefreshControl *c = [[UIRefreshControl alloc] initWithFrame:CGRectZero];
    [self.tableView addSubview:c];
    [c addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRefreshLocations:) name:MPrintDidRefreshLocationsNotification object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        [self.tableView reloadData];
    }];
}

#pragma mark - Notification Handlers

-(void)didRefreshLocations:(NSNotification *)note
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate/DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [Location locationCount];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NO"];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"NO"];
    
    __weak Location *location = [Location locationAtIndex:indexPath.row];
    cell.textLabel.text = location.displayName;
    cell.detailTextLabel.text = location.location;
    return cell;
}

@end
