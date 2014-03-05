//
//  UsageViewController.m
//  BluePrinter
//
//  Created by David Quesada on 3/3/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "UsageViewController.h"
#import "Usage.h"
#import "SVProgressHUD.h"
#import "UITableView+Notice.h"

#define DIVIDER_FOOTER_CELL_TAG 875

static Usage *lastUsage;

@interface UsageViewController ()
{
    BOOL _isShowingHUD;
}

@property Usage *usage;
-(UITableViewCell *)cellForRow:(NSInteger)row inCategory:(UsageCategory *)category;
-(UITableViewCell *)dividerFooterCell;

-(void)loadUsage:(UIRefreshControl *)sender;
@end

@implementation UsageViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] initWithFrame:CGRectZero];
    [self.tableView addSubview:refresh];
    [refresh addTarget:self action:@selector(loadUsage:) forControlEvents:UIControlEventValueChanged];
    [self loadUsage:nil];
    
//    refresh.tintColor = [UIColor grayColor];
    
    self.usage = lastUsage;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"dividerFooter"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isShowingHUD)
        [SVProgressHUD show];
}

-(void)loadUsage:(UIRefreshControl *)sender
{
    _isShowingHUD = YES;
    [SVProgressHUD show];
    
    [Usage fetchWithCompletion:^(NSMutableArray *objects, MPrintResponse *response) {
        if (response.success)
        {
            self.usage = [objects lastObject];
            lastUsage = self.usage;
            self.tableView.noticeText = nil;
        }
        else
        {
            self.usage = nil;
            lastUsage = nil;
            self.tableView.noticeText = @"Unable to get usage info.";
        }
        
        [self.tableView reloadData];
        _isShowingHUD = NO;
        [SVProgressHUD dismiss];
        
        [sender endRefreshing];
    }];
}

-(UITableViewCell *)cellForRow:(NSInteger)row inCategory:(UsageCategory *)category
{
    UITableViewCell *cell = nil;
    
    if (row == 0)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"categoryCell"];
        cell.textLabel.text = category.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d / %d %@", category.totalUsage, category.totalAllocation, category.unit];
    } else if (row == 1)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"allowancesHeader"];
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 320);
    } else if (category.allocations.count)
    {
        UsageAllocation *item = category.allocations[row - 2];
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"allowanceCell"];
        cell.textLabel.text = item.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", item.allocation];
        
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 320);
    } else
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"noneCell"];
    }
    
    return cell;
}

-(UIView *)dividerFooterCell;
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"dividerFooter"];
    if (cell.tag != DIVIDER_FOOTER_CELL_TAG)
    {
        cell.frame = CGRectMake(0, 0, 320, 12);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(15, 11, 290, .5)];
        view.backgroundColor = [UIColor lightGrayColor];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [cell addSubview:view];
        cell.tag = DIVIDER_FOOTER_CELL_TAG;
    }
    return cell;
}

#pragma mark - UITableViewDataSource/Delegate Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 0;
    UsageCategory *cat = _usage.categories[section];
    
    count += 1; // For the title cell.
    count += 1; // "Allowances";
    if (cat.allocations.count)
        count += cat.allocations.count;
    else
        count ++;
    
    count += 1; // For the footer thing.
    return count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _usage.categories.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == ([self tableView:tableView numberOfRowsInSection:indexPath.section] - 1))
        return [self dividerFooterCell];
    return [self cellForRow:indexPath.row inCategory:_usage.categories[indexPath.section]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    
    if (row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1)
        return 12;
    
    if (row == 0)
        return 68.0;
    else if (row == 1)
        return 28.0;
    return 32.0;
}

@end
