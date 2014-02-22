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
#import "MPrintResponse.h"
#import "Account.h"
#import "AppDelegate.h"

typedef NS_ENUM(NSInteger, AccountButtonMode)
{
    AccountButtonModeLogIn,
    AccountButtonModeLogOut,
    AccountButtonModeLoading,
};

@interface ServicesViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    BOOL _hasReloaded;
    __weak UIRefreshControl *_refreshControl;
}
@property (weak) IBOutlet UITableView *tableView;

@property NSArray *sections;
-(void)createSections;

-(void)didRefreshServices:(NSNotification *)note;

-(void)logIn:(id)sender;
-(void)logOut:(id)sender;

-(void)userDidLogIn:(NSNotification *)note;
-(void)userDidLogOut:(NSNotification *)note;

-(void)setAccountButtonMode:(AccountButtonMode)mode;

@end

@implementation ServicesViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    UIRefreshControl *ref = [[UIRefreshControl alloc] init];
    [ref addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    _refreshControl = ref;
    [self.tableView addSubview:ref];
    
    self.tableView.rowHeight = 60.0;
    self.tableView.sectionHeaderHeight = 30.0;
    
    _sections = @[ [NSMutableArray new], [NSMutableArray new], [NSMutableArray new], ];
    [self createSections];
    
    [self reload:(id)self.tableView.tableHeaderView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRefreshServices:) name:MPrintDidRefreshServicesNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogIn:) name:MPrintUserDidLogInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogOut:) name:MPrintUserDidLogOutNotification object:nil];
    [self setAccountButtonMode:AccountButtonModeLogIn];
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
    if (!_refreshControl.isRefreshing)
        [_refreshControl beginRefreshing];
    [self setAccountButtonMode:AccountButtonModeLoading];
    [Service refreshServices:^(NSMutableArray *objects, MPrintResponse *response) {
        [self createSections];
        [_refreshControl endRefreshing];
        [self.tableView reloadData];
        
        if (response.uniqname)
            [self setAccountButtonMode:AccountButtonModeLogOut];
        else
            [self setAccountButtonMode:AccountButtonModeLogIn];
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

-(void)setAccountButtonMode:(AccountButtonMode)mode
{
    UIBarButtonItem *item = nil;
    UIActivityIndicatorView *view = nil;
    
    if (mode == AccountButtonModeLoading)
    {
        view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        item = [[UIBarButtonItem alloc] initWithCustomView:view];
    } else if (mode == AccountButtonModeLogIn)
    {
        item = [[UIBarButtonItem alloc] initWithTitle:@"Log In" style:UIBarButtonItemStyleBordered target:self action:@selector(logIn:)];
    } else if (mode == AccountButtonModeLogOut)
    {
        item = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStyleBordered target:self action:@selector(logOut:)];
    }
    
    self.navigationItem.leftBarButtonItem = item;
    [view startAnimating];
}

-(void)logOut:(id)sender
{
    [Account logout:^(BOOL success) {

    }];
}

-(void)logIn:(id)sender
{
    [[AppDelegate sharedDelegate] showLoginViewController];
}

#pragma mark - Notification Handlers

-(void)didRefreshServices:(NSNotification *)note
{
    [self createSections];
    [self.tableView reloadData];
}

-(void)userDidLogIn:(NSNotification *)note
{
    [self setAccountButtonMode:AccountButtonModeLogOut];
}

-(void)userDidLogOut:(NSNotification *)note
{
    [self setAccountButtonMode:AccountButtonModeLogIn];
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
