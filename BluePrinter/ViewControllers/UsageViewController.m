//
//  UsageViewController.m
//  BluePrinter
//
//  Created by David Quesada on 3/3/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "UsageViewController.h"
#import "SVProgressHUD.h"

#define DIVIDER_FOOTER_CELL_TAG 875

static Usage *lastUsage;
static const SVProgressHUDMaskType UsageViewControllerHUDMaskType = SVProgressHUDMaskTypeBlack;

@interface UsageViewController ()
{
    BOOL _isShowingHUD;
    NSNumberFormatter *balanceFormatter;
    
    UIColor *positiveBalanceColor;
    UIColor *negativeBalanceColor;
    
    NSDictionary *estimationCountAttributes;
    NSDictionary *estimationTypeAttributes;
}

@property Usage *usage;
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
        [SVProgressHUD showWithMaskType:UsageViewControllerHUDMaskType];
}

-(void)loadUsage:(UIRefreshControl *)sender
{
    _isShowingHUD = YES;
    [SVProgressHUD showWithMaskType:UsageViewControllerHUDMaskType];
    
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

-(UIView *)dividerFooterCell;
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"dividerFooter"];
    if (cell.tag != DIVIDER_FOOTER_CELL_TAG)
    {
        cell.frame = CGRectMake(0, 0, 320, 12);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
// Enable/disable hairline
#if 0
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(15, 11, 290, .5)];
        view.backgroundColor = [UIColor lightGrayColor];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [cell addSubview:view];
#endif
        cell.tag = DIVIDER_FOOTER_CELL_TAG;
    }
    return cell;
}

-(NSArray *)usageTypesToEstimate
{
    return @[ @(UsageTypeBlackAndWhite), @(UsageTypeColor), @(UsageTypeTabloid) ];
}

-(BOOL)sectionHasFooter:(int)section
{
    return YES;
}

#pragma mark - UITableViewDataSource/Delegate Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            if ([self usageTypesToEstimate].count)
                return 3 + [self usageTypesToEstimate].count * 2 - 1;
            else
                return 3;
        case 1:
            return 5; // Header + 3 stats + footer
        default:
            break;
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(UITableViewCell *)balanceCell
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"balanceCell"];
    if (_usage == nil)
    {
        cell.textLabel.text = @"$--.--";
        cell.textLabel.textColor = [UIColor blackColor];
    }
    else
    {
        if (!balanceFormatter)
        {
            balanceFormatter = [[NSNumberFormatter alloc] init];
            balanceFormatter.currencySymbol = @"$";
            balanceFormatter.currencyCode = @"USD";
            balanceFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
            
            positiveBalanceColor = [UIColor colorWithRed:0 green:.55 blue:0 alpha:1];
            negativeBalanceColor = [UIColor colorWithRed:.7 green:0 blue:0 alpha:1];
        }
        double bal = _usage.balance;
        
        cell.textLabel.text = [balanceFormatter stringFromNumber:@(bal)];
        if (bal < 0)
            cell.textLabel.textColor = negativeBalanceColor;
        else if (bal < 0.005)
            cell.textLabel.textColor = [UIColor blackColor];
        else
            cell.textLabel.textColor = positiveBalanceColor;
    }
    return cell;
}

// This method is a doozy.
-(UITableViewCell *)estimationCellAtIndex:(int)index
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"estimationCell"];
    
    if (!estimationCountAttributes)
    {
        NSAttributedString *str = cell.textLabel.attributedText;
        estimationCountAttributes = [str attributesAtIndex:0 effectiveRange:NULL];
        estimationTypeAttributes = [str attributesAtIndex:1 effectiveRange:NULL];
    }
    
    NSArray *ests = [self usageTypesToEstimate];
    UsageType typ = (UsageType)[ests[index] intValue];
    
    int remaining = [_usage estimatedRemainingUsagesOfType:typ];
    NSString *costDesc = [Usage costDescriptionForUsageType:typ];
    NSString *desc = @" units";
    
    switch (typ)
    {
        case UsageTypeBlackAndWhite: desc = @"  black & white pages"; break;
        case UsageTypeColor: desc = @"  color pages"; break;
        case UsageTypeTabloid: desc = @"  tabloid pages"; break;
    }

    // Singular hack.
    if (remaining == 1)
        desc = [desc substringToIndex:desc.length - 1];
    
    // Show "--" if there is no usage object loaded.
    NSString *countStr = _usage ? [NSString stringWithFormat:@"%d", remaining] : @"--";
    
    NSMutableAttributedString *s1 = [[NSMutableAttributedString alloc] initWithString:countStr attributes:estimationCountAttributes];
    NSAttributedString *s2 = [[NSAttributedString alloc] initWithString:desc attributes:estimationTypeAttributes];
    
    [s1 appendAttributedString:s2];
    
    cell.textLabel.attributedText = s1;
    cell.detailTextLabel.text = costDesc;
        
    return cell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == ([self tableView:tableView numberOfRowsInSection:indexPath.section] - 1))
        if ([self sectionHasFooter:indexPath.section])
            return [self dividerFooterCell];
    
    int section = indexPath.section;
    int row = indexPath.row;
    
    if (section == 0)
    {
        if (row == 0)
        {
            UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"balancesHeader"];
//            cell.textLabel.textAlignment = nstextali
            return cell;
        }
        if (row == 1)
            return [self balanceCell];
        if (row % 2 == 0)
            return [self estimationCellAtIndex:(row - 2) / 2];
        return [tableView dequeueReusableCellWithIdentifier:@"estimationSeparator"];
    }
    else if (section == 1)
    {
        if (row == 0)
            return [tableView dequeueReusableCellWithIdentifier:@"usageHeader"];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"statCell"];
        if (row == 1)
        {
            cell.textLabel.text = @"Total Number of Jobs";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", _usage.totalJobs];
        }
        else if (row == 2)
        {
            cell.textLabel.text = @"Total Sheets Printed";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", _usage.totalSheets];
        }
        else if (row == 3)
        {
            cell.textLabel.text = @"Total Pages Printed";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", _usage.totalPages];
        }
        if (!_usage)
            cell.detailTextLabel.text = @"--";
        return cell;
    }
    
    return [UITableViewCell new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    
    // Section dividers
    if ((row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) && [self sectionHasFooter:indexPath.section])
        return 15;
    
#define HeaderHeight 35.0
    
    if (indexPath.section == 0)
    {
        if (row == 0)
            return HeaderHeight;    // "Printing Cre:" header
        else if (row == 1)
            return 98.0;        // "$12.34" label
        if (row % 2 == 0)
            return 32;              // "45 black & white pages"
        else if (row % 2 == 1)
            return 15;
    }
    
    //
    else if (indexPath.section == 1)
    {
        if (row == 0)
            return 27;
        return 32.0;
    }
    
    if (row == 0)
        return 68.0;
    else if (row == 1)
        return 28.0;
    return 32.0;
}

@end
