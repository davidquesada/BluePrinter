//
//  JobsViewController.m
//  BluePrinter
//
//  Created by David Paul Quesada on 1/14/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "JobsViewController.h"
#import "Account.h"
#import "PrintJob.h"

@interface JobsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property(weak) UIRefreshControl *refreshControl;
@property(weak) IBOutlet UITableView *tableView;

-(void)refresh:(UIRefreshControl *)sender;
-(void)didRefreshJobs:(NSNotification *)note;

@end

@implementation JobsViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    UIRefreshControl *ref = [[UIRefreshControl alloc] init];
    self.refreshControl = ref;
    [self.tableView addSubview:ref];
    [ref addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRefreshJobs:) name:MPrintDidRefreshUserJobsNotification object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)refresh:(UIRefreshControl *)sender
{
    if (!_refreshControl.isRefreshing)
        [_refreshControl beginRefreshing];
    [PrintJob refreshUserJobs:^(BOOL success) {
        [_refreshControl endRefreshing];
    }];
}

#pragma mark - IBActions

-(IBAction)logout:(id)sender
{
    [Account logout:^(BOOL success) {
        NSLog(@"YO");
    }];
}

#pragma mark - Notification Handlers

-(void)didRefreshJobs:(NSNotification *)note
{
    [self.tableView reloadData];
}

#pragma mark - UITableView Stuff

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"jobCell"];
    
    PrintJob *job = [PrintJob userJobs][indexPath.row];
    
    cell.textLabel.text = job.name;
    cell.detailTextLabel.text = job.printerDisplayName;
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [PrintJob userJobs].count;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Cancel";
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PrintJob *job = [PrintJob userJobs][indexPath.row];
    if (job.cancellable)
        return UITableViewCellEditingStyleDelete;
    return UITableViewCellEditingStyleNone;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PrintJob *job = [PrintJob userJobs][indexPath.row];
    [job cancel:^(NSMutableArray *objects, MPrintResponse *response) {
        NSLog(@"Did finish cancelling job.");
        [job refresh:^(NSMutableArray *objects, MPrintResponse *response) {
            NSLog(@"Did finish post-cancellation refresh.");
            
            [self.tableView reloadData];
        }];
    }];
}

@end
