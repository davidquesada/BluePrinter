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

@interface ServicesViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak) IBOutlet UITableView *tableView;

@property NSMutableArray *connectedServices;
@property NSMutableArray *disconnectedServices;
@end

@implementation ServicesViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    UIRefreshControl *ref = [[UIRefreshControl alloc] init];
    [ref addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:ref];
    
    self.connectedServices = [NSMutableArray new];
    self.disconnectedServices = [NSMutableArray new];
}

-(void)reload:(UIRefreshControl *)sender
{
    [Service fetchWithCompletion:^(NSMutableArray *objects, MPrintResponse *response) {
        for (Service *svc in objects)
        {
            if (svc.isConnected)
                [self.connectedServices addObject:svc];
            else
                [self.disconnectedServices addObject:svc];
        }
        [sender endRefreshing];
        [self.tableView reloadData];
    }];
}

-(IBAction)showLocalFiles:(id)sender
{
    [self.navigationController pushViewController:[[FilesViewController alloc] initWithService:[Service localService]] animated:YES];
}

#pragma mark - UITableView Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Connected Services";
    if (section == 1)
        return @"Inactive Services";
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return self.connectedServices.count;
    if (section == 1)
        return self.disconnectedServices.count;
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"serviceCell"];
    NSArray *array = (indexPath.section ? self.disconnectedServices : self.connectedServices);
    Service *service = array[indexPath.row];
    
    cell.textLabel.text = service.description;
    
    cell.accessoryType = (service.isConnected ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone);
    
    cell.selectionStyle = (service.isConnected ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone);
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section != 0)
        return;
    Service *service = self.connectedServices[indexPath.row];
    if (!service.isConnected)
        return;
    NSLog(@"TODO: Show the files in this service");
}

@end
