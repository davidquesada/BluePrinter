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


@interface JobsViewController ()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
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
        NSDebugLog(@"Did finish cancelling job.");
        [job refresh:^(NSMutableArray *objects, MPrintResponse *response) {
            NSDebugLog(@"Did finish post-cancellation refresh.");
            
            [self.tableView reloadData];
        }];
    }];
}

@end

@interface JobCell()<UIGestureRecognizerDelegate>
{
    UIPanGestureRecognizer *pan;
    UILabel *stateLabel;
    CGRect originalColorFrame;
    BOOL isShowingStatus;
}
+(UIColor *)colorForPrintJobState:(PrintJobState)state;
@end

BOOL _jobCellLegacy;

@implementation JobCell

+(void)initialize
{
    _jobCellLegacy = ([[[UIDevice currentDevice] systemVersion] integerValue] < 7);
}

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
    self.backgroundColor = colorView.backgroundColor;
    self.contentView.backgroundColor = [UIColor whiteColor];

    stateLabel.text = job.stateDescription;
    
    if (_jobCellLegacy)
        self.textLabel.textColor = [self.class colorForPrintJobState:job.state];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        colorView = [self viewWithTag:7777];
        colorView.autoresizingMask = 0;
        
        stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, 135, colorView.frame.size.height)];
        stateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24];
        stateLabel.textColor = [UIColor whiteColor];
        stateLabel.textAlignment = NSTextAlignmentCenter;
        [colorView addSubview:stateLabel];
        
        self.textLabel.backgroundColor = [UIColor whiteColor];
        self.detailTextLabel.backgroundColor = [UIColor whiteColor];
        
        if (_jobCellLegacy)
            [colorView removeFromSuperview];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if (!pan && !_jobCellLegacy)
    {
        pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
        pan.cancelsTouchesInView = NO;
        pan.delegate = self;
        [self addGestureRecognizer:pan];

        CGRect frame = colorView.frame;
        frame.origin.x -= 320;
        frame.size.width += 320;
        
        colorView.frame = frame;
        colorView.autoresizingMask = 0;
        colorView.clipsToBounds = YES;
    }
}

-(void)didPan:(UIPanGestureRecognizer *)sender
{
    if (self.isEditing)
        return;

    if (sender.state == UIGestureRecognizerStateBegan)
    {
        isShowingStatus = YES;
    }
    if (sender.state == UIGestureRecognizerStateChanged)
    {
        CGFloat xoff = [sender translationInView:self].x;
        if (xoff < 0) xoff = 0;
        if (xoff > 160) xoff = 160;

        self.contentView.frame = CGRectOffset(self.contentView.bounds, xoff, 0);
        
        CGRect frame = colorView.frame;
        frame.origin.x = -xoff;
        frame.size.width = 25 + xoff;
        colorView.frame = frame;
    }
    if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateFailed || sender.state == UIGestureRecognizerStateCancelled)
    {
        isShowingStatus = NO;
        id animations =
        ^{
            CGRect frame = colorView.frame;
            frame.origin.x = 0;
            frame.size.width = 25;
            colorView.frame = frame;

            self.contentView.frame = self.contentView.bounds;
        };
        [UIView animateWithDuration:.25 delay:0 usingSpringWithDamping:10 initialSpringVelocity:.9 options:0 animations:animations completion:nil];
    }
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if (!_jobCellLegacy)
    {
        if (editing)
            self.backgroundColor = [UIColor whiteColor];
        else
            self.backgroundColor = colorView.backgroundColor;
    }
}

#pragma mark - UIGestureRecognizerDelegate Methods
/* 
 * These two methods work together to make sure only one of the
 * three applicable gestures are active:
 *  - Scrolling
 *  - Swiping left to reveal the 'Delete' button
 *  - Swiping right to reveal the status.
 */

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (isShowingStatus || (otherGestureRecognizer.state == UIGestureRecognizerStateBegan))
        return NO;
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    // This might happen for other types of gestures (i.e. There is a UILongPressGestureRecognizer on the cells)
    if (![gestureRecognizer respondsToSelector:@selector(translationInView:)])
    {
        return YES;
    }
    CGPoint translation = [gestureRecognizer translationInView:self.superview];
    //might have to change view to tableView
    //check for the horizontal gesture
    if ((fabsf(translation.x) > fabsf(translation.y))
        && (translation.x > 0)) {
        return YES;
        NSDebugLog(@"Panning");
    }
    return NO;
}

@end
