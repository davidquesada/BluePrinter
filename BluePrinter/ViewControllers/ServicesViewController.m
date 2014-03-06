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
#import "LocalFilesViewController.h"
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

-(NSInteger)indexToInsertService:(Service *)service inSection:(NSInteger)section;
-(void)moveServiceAtIndexPath:(NSIndexPath *)indexPath toSection:(NSInteger)section;

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

-(NSIndexPath *)indexPathForService:(Service *)service
{
    for (int i = 0; i < _sections.count; ++i)
    {
        __weak NSArray *sec = _sections[i];
        NSInteger loc = [sec indexOfObjectIdenticalTo:service];
        if (loc != NSNotFound)
            return [NSIndexPath indexPathForRow:loc inSection:i];
    }
    return nil;
}

-(NSInteger)indexToInsertService:(Service *)service inSection:(NSInteger)section
{
    if (_sections.count < 3)
        return 0;
    NSArray *dcSection = _sections[section];
    if (dcSection.count == 0)
        return 0;
    
    NSRange range = NSMakeRange(0, dcSection.count);
    return [dcSection indexOfObject:service inSortedRange:range options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(Service *obj1, Service *obj2) {
        
        int a = (int)obj1.type, b = (int)obj2.type;
        if (a == b)
            return NSOrderedSame;
        if (a < b)
            return NSOrderedAscending;
        return NSOrderedDescending;
        //        return [[obj1 valueForKey:@"type"] compare:[obj2 valueForKey:@"type"]];
    }];
}

-(void)moveServiceAtIndexPath:(NSIndexPath *)indexPath toSection:(NSInteger)section
{
    Service *service = _sections[indexPath.section][indexPath.row];
    int idx = [self indexToInsertService:service inSection:section];
    NSIndexPath *dest = [NSIndexPath indexPathForRow:idx inSection:section];
    
    [_sections[indexPath.section] removeObject:service];
    [_sections[dest.section] insertObject:service atIndex:dest.row];
    
    [self.tableView beginUpdates];
    [self.tableView moveRowAtIndexPath:indexPath toIndexPath:dest];
    [self.tableView endUpdates];
    
    [self.tableView reloadRowsAtIndexPaths:@[ dest ] withRowAnimation:UITableViewRowAnimationFade];
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
    cell.detailTextLabel.text = (service.isConnected ? nil : @"Tap to connect");
    cell.accessoryType = (service.isConnected ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone);
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
    {
        [self.navigationController pushViewController:[[LocalFilesViewController alloc] initWithService:_sections[0][0]] animated:YES];
        return;
    }

    Service *service = _sections[indexPath.section][indexPath.row];
    
    if (service.isConnected)
    {
        FilesViewController *controller = [[FilesViewController alloc] initWithService:service];
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [service connect:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        // The connect didn't work, so don't try to do any fancy animations.
        if (!service.isConnected)
            return;
        
        [self moveServiceAtIndexPath:indexPath toSection:1];
    }];
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Disconnect";
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Service *service = _sections[indexPath.section][indexPath.row];
    if (service.isConnected && service.supportsDisconnect)
        return UITableViewCellEditingStyleDelete;
    return UITableViewCellEditingStyleNone;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Service *service = _sections[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.editing = NO;
    self.tableView.editing = NO;
    
    NSAssert(service.supportsDisconnect, @"This service doesn't support disconnect: %@", service);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [service disconnect:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        // The disconnect didn't work, so don't try to do any fancy animations.
        if (service.isConnected)
            return;

        [self moveServiceAtIndexPath:indexPath toSection:2];
    }];
}

@end
