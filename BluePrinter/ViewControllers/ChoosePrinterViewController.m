//
//  ChoosePrinterViewController.m
//  BluePrinter
//
//  Created by David Quesada on 2/15/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "ChoosePrinterViewController.h"
#import "Location.h"

@interface ChoosePrinterViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>
@property UISearchDisplayController *sdc;

@property NSArray *sections;
@property NSArray *searchResults;

@property(weak) UIRefreshControl *refreshControl;
@property(weak) UITableView *tableView;

-(void)loadSearchResultsForString:(NSString *)string;

-(void)createSections;

@end

@implementation ChoosePrinterViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Printing Locations";
    
    // As it turns out, for whatever undocumented BS reason, this works well.
    // No bugs when fast enabling/disabling search, no problems with translucent
    // or opaque bars.
    self.automaticallyAdjustsScrollViewInsets = self.navigationController.navigationBar.isTranslucent;
}

-(void)loadView
{
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.view = table;
    self.tableView = table;
    
    table.dataSource = self;
    table.delegate = self;
    
    table.rowHeight = 52;
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];

    // I like the subtle effect this has.
    UIView *bg = [[[[[[searchBar subviews]lastObject]subviews]lastObject]subviews]lastObject]; // WOO!
    if ([[[[bg class] description] lowercaseString] rangeOfString:@"backgroundview"].location != NSNotFound)
        [bg removeFromSuperview];
    
    table.tableHeaderView = searchBar;

    UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    /*contents controller is the UITableViewController, this let you to reuse
     the same TableViewController Delegate method used for the main table.*/
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    
    // Due to a UIKit bug, we need to keep an additional strong reference to this.
    self.sdc = searchDisplayController;
    
    UIRefreshControl *ref = [[UIRefreshControl alloc] init];
    [ref addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:ref];
    self.refreshControl = ref;
    
    [self createSections];
    [self.tableView reloadData];
    
    [self.tableView setContentOffset:CGPointMake(0, 44.0) animated:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![Location locationCount])
        [self performSelector:@selector(refresh) withObject:nil afterDelay:.005];
}

-(void)refresh
{
    if (!self.refreshControl.isRefreshing)
        [self.refreshControl beginRefreshing];
    [Location refreshLocations:^(BOOL success) {
        if (success)
        {
            [self createSections];
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
        [Location refreshRecentLocations:^(BOOL success) {
            if (success)
            {
                [self createSections];
                [self.tableView reloadData];
            }
        }];
    }];
}

-(void)createSections
{
    NSArray *a = [Location recentLocations];
    NSArray *b = [Location allLocations];
    
    if (!a.count)
        a = @[[NSNull null]];
    if (!b.count)
        b = @[[NSNull null]];
    
    _sections = @[ a, b, ];
}

-(void)dealloc
{
    self.sdc = nil;
}

-(void)loadSearchResultsForString:(NSString *)string
{
    NSArray *locs = [Location allLocations];
    self.searchResults = [locs objectsAtIndexes:[locs indexesOfObjectsPassingTest:^BOOL(Location *obj, NSUInteger idx, BOOL *stop) {
        
        NSString *str;
        
        str = obj.displayName;
        if (str && ([str rangeOfString:string options:NSCaseInsensitiveSearch].location != NSNotFound))
            return YES;
        
        str = obj.location;
        if (str && ([str rangeOfString:string options:NSCaseInsensitiveSearch].location != NSNotFound))
            return YES;
        
        return NO;
    }]];
}

#pragma mark - UISearchDisplayControllerDelegate Methods

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self loadSearchResultsForString:searchString];
    return YES;
}

-(void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    // Fix a bug in iOS. It's possible to make the search bar disappear out of the view
    // hierarchy and then cause an EXC_BAD_ACCESS. So here's basically where it ordinarily
    // would leave, but let's steal it back before it gets lost.
    self.tableView.tableHeaderView = controller.searchBar;
    [self.tableView addSubview:controller.searchBar];
}

#pragma mark - UITableView Stuff

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _tableView)
        return 2;
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // No section header for search results.
    if (tableView != _tableView)
        return nil;
    if (section == 0)
        return @"Recent Locations";
    return @"All Locations";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Location *location = nil;
    if (tableView == _tableView)
        location = _sections[indexPath.section][indexPath.row];
    else
        location = [_searchResults objectAtIndex:indexPath.row];
    
    if (location == (id)[NSNull null])
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nope"];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"nope"];
            cell.textLabel.text = @"None";
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
    
    
    UITableViewCell *cell;
    
    if (location.status == LocationStatusOK)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"enabled"];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"enabled"];
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"disabled"];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"disabled"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
            
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            lbl.text = @"🚫";
            lbl.font = [UIFont systemFontOfSize:25];
            lbl.textAlignment = NSTextAlignmentRight;
            cell.accessoryView = lbl;
        }
    }
    
    cell.textLabel.text = location.displayName;
    cell.detailTextLabel.text = location.location;
    
    if (location.status == LocationStatusOK)
    {
        UITableViewCellAccessoryType acc = UITableViewCellAccessoryNone;
        if ([_selectedLocation.name isEqualToString:location.name])
            acc = UITableViewCellAccessoryCheckmark;
        
        cell.accessoryType = acc;
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tableView)
        return [_sections[section] count];
    return _searchResults.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Location *loc = nil;
    
    if (tableView == _tableView)
        loc = _sections[indexPath.section][indexPath.row];
    else
        loc = _searchResults[indexPath.row];
    
    if (loc == (id)[NSNull null])
        return;
    
    if (loc.status != LocationStatusOK)
        return;
    
    if ([self.delegate respondsToSelector:@selector(choosePrinterViewController:didChoosePrintLocation:)])
        [self.delegate choosePrinterViewController:self didChoosePrintLocation:loc];
}

@end
