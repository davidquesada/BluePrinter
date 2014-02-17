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
@property NSArray *searchResults;

-(void)loadSearchResultsForString:(NSString *)string;

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
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    table.tableHeaderView = searchBar;

    UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    /*contents controller is the UITableViewController, this let you to reuse
     the same TableViewController Delegate method used for the main table.*/
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    
    // Due to a UIKit bug, we need to keep an additional strong reference to this.
    self.sdc = searchDisplayController;
}

-(void)refresh
{
    
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

#pragma mark - UITableView Stuff

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"yo"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"yo"];
    }
    
    Location *location = nil;
    
    if (tableView == (id)self.view)
        location = [Location locationAtIndex:indexPath.row];
    else
        location = [_searchResults objectAtIndex:indexPath.row];
    
    cell.textLabel.text = location.displayName;
    cell.detailTextLabel.text = location.location;
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == (id)self.view)
        return [Location locationCount];
    return _searchResults.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Location *loc = nil;
    
    if (tableView == (id)self.view)
        loc = [Location locationAtIndex:indexPath.row];
    else
        loc = _searchResults[indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(choosePrinterViewController:didChoosePrintLocation:)])
        [self.delegate choosePrinterViewController:self didChoosePrintLocation:loc];
}

@end
