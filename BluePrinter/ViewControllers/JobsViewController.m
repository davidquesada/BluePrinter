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
#import "UITableView+Notice.h"


@interface JobCell : UITableViewCell
{
    __weak IBOutlet UIView *colorView;
}
-(void)setPrintJob:(PrintJob *)job;
@end


@interface JobsViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    BOOL _hasAppeared;
}
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
    
    self.tableView.noticeBackgroundColor = [UIColor whiteColor];
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // This fixes a weird thing that causes one of two bugs when the
    // 'notice' property of the tableview is set:
    // 1. Cell dividers are shown overlaying the notice view.
    // 2. Effectively, the contentSize of the tableview is ~80 pt too
    //    much, and the tableview can be scrollable when it shouldn't be.
    if (!_hasAppeared)
    {
        _hasAppeared = YES;
        [self didRefreshJobs:nil];
    }
}

#pragma mark - Notification Handlers

-(void)didRefreshJobs:(NSNotification *)note
{
    if ([PrintJob userJobs].count)
        self.tableView.noticeText = nil;
    else
        self.tableView.noticeText = @"No Recent Jobs";
    [self.tableView reloadData];
    
    self.tableView.tableHeaderView = self.tableView.tableHeaderView;
}

#pragma mark - UITableView Stuff

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JobCell *cell = [tableView dequeueReusableCellWithIdentifier:@"jobCell"];
    
    PrintJob *job = [PrintJob userJobs][indexPath.row];
    [cell setPrintJob:job];
    
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

@interface JobCell()
+(UIColor *)colorForPrintJobState:(PrintJobState)state;
@end

@implementation JobCell

+(UIColor *)colorForPrintJobState:(PrintJobState)state
{
    static NSDictionary *dict = nil;
    if (!dict)
        dict = @{
                 @(PrintJobStateCancelled) : [UIColor blackColor],
                 @(PrintJobStateCompleted) : [UIColor colorWithRed:.1 green:.8 blue:.1 alpha:1.0],
                 @(PrintJobStateConverting) : [UIColor orangeColor],
                 @(PrintJobStateFailed) : [UIColor colorWithRed:1.0 green:.1 blue:.1 alpha:1.0],
                 @(PrintJobStateProcessing) : [UIColor colorWithRed:.1 green:.1 blue:.7 alpha:1.0],
                  };
    return dict[@(state)];
}

-(void)setPrintJob:(PrintJob *)job
{
    static NSDateFormatter *formatter = nil;
    if (!formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
    }
    
    self.textLabel.text = job.name;
    NSString *dateString = [formatter stringFromDate:job.creationTime];
    self.detailTextLabel.text = [NSString stringWithFormat:@"Submitted %@\n%@", dateString, job.printerDisplayName ];
    
    colorView.backgroundColor = [self.class colorForPrintJobState:job.state];
}

@end
