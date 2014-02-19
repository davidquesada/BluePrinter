//
//  ServicesViewController.m
//  BluePrinter
//
//  Created by David Quesada on 1/29/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "ServicesViewController.h"
#import "Service.h"
#import "FilesViewController.h"
#import "MPrintCosignManager.h"

@interface ServicesViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    BOOL _hasReloaded;
}
@property (weak) IBOutlet UITableView *tableView;

@property NSArray *sections;
-(void)createSections;

-(void)didRefreshServices:(NSNotification *)note;

@end

@implementation ServicesViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    UIRefreshControl *ref = [[UIRefreshControl alloc] init];
    [ref addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:ref];
    
    self.tableView.rowHeight = 60.0;
    self.tableView.sectionHeaderHeight = 30.0;
    
    _sections = @[ [NSMutableArray new], [NSMutableArray new], [NSMutableArray new], ];
    [self createSections];
    
    [self reload:(id)self.tableView.tableHeaderView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRefreshServices:) name:MPrintDidRefreshServicesNotification object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_hasReloaded)
    {
        _hasReloaded = YES;
        [self reload:(id)self.tableView.tableHeaderView];
    }
}

-(void)reload:(UIRefreshControl *)sender
{
    if (!sender.isRefreshing)
        [sender beginRefreshing];
    [Service refreshServices:^(NSMutableArray *objects, MPrintResponse *response) {
        [self createSections];
        [sender endRefreshing];
        [self.tableView reloadData];
    }];
}

-(IBAction)showLocalFiles:(id)sender
{
    [self.navigationController pushViewController:[[FilesViewController alloc] initWithService:[Service localService]] animated:YES];
}

-(void)createSections
{
    for (NSMutableArray *section in _sections)
        [section removeAllObjects];
    for (Service *service in [Service allServices])
    {
        if (service.type == ServiceTypeLocal)
            [_sections[0] addObject:service];
        else if (service.isConnected)
            [_sections[1] addObject:service];
        else
            [_sections[2] addObject:service];
    }
}

#pragma mark - Notification Handlers

-(void)didRefreshServices:(NSNotification *)note
{
    [self createSections];
    [self.tableView reloadData];
}

#pragma mark - UITableView Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sections.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1 && [_sections[1] count])
        return @"Connected Services";
    if (section == 2 && [_sections[2] count])
        return @"Inactive Services";
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_sections[section] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"serviceCell"];
    Service *service = _sections[indexPath.section][indexPath.row];
    
    cell.textLabel.text = service.description;
    
    cell.accessoryType = (service.isConnected ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone);
    
    cell.selectionStyle = (service.isConnected ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone);
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    Service *service = _sections[indexPath.section][indexPath.row];
    if (!service.isConnected)
        return;
    
    FilesViewController *controller = [[FilesViewController alloc] initWithService:service];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
