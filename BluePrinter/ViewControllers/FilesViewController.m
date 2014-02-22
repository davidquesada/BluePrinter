//
//  FilesViewController.m
//  BluePrinter
//
//  Created by David Paul Quesada on 1/14/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "FilesViewController.h"
#import "Service.h"
#import "ServiceFile.h"
#import "PrintRequest.h"
#import "PrintJobTableViewController.h"
#import "ServiceFile+Icons.h"

@interface FilesViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    BOOL _hasAppeared;
}
@property(readwrite) Service *service;
@property(readwrite) NSString *path;

@property NSArray *files;

@property(weak) UITableView *tableView;
@property(weak) UIRefreshControl *refresh;
@end

@implementation FilesViewController

-(id)initWithService:(Service *)service path:(NSString *)path
{
    if ((self = [self init]))
    {
        self.service = service;
        self.path = path;
    }
    return self;
}
-(id)initWithService:(Service *)service
{
    return self = [self initWithService:service path:@"/"];
}
-(id)initWithServiceFile:(ServiceFile *)file
{
    NSAssert(file.isDirectory, @"ServiceFile 'file' must be a directory.");
    return self = [self initWithService:file.service path:file.fullpath];
}

-(void)loadView
{
    self.view = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView = (id)self.view;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 52.0;
    [self.tableView registerNib:[UINib nibWithNibName:@"FileCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"fileCell"];
    
    UIRefreshControl *ref = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:ref];
    [ref addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    if (![self.path isEqualToString:@"/"])
        self.navigationItem.title = [self.path lastPathComponent];
    else
        self.navigationItem.title = self.service.description;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    if (!_hasAppeared)
    {
        _hasAppeared = YES;
        [self refresh:self.refresh];
    }
}

-(void)refresh:(UIRefreshControl *)sender
{
    if (!self.refresh.isRefreshing)
        [self.refresh beginRefreshing];
    [self.service fetchDirectoryInfoForPath:self.path completion:^(NSMutableArray *objects, MPrintResponse *response) {
        self.files = objects;
        [sender endRefreshing];
        [self.tableView reloadData];
    }];
}

#pragma mark - UITableView Stuff

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fileCell"];
    ServiceFile *file = _files[indexPath.row];
    
    cell.imageView.image = [file imageRepresentationInListView];
    cell.textLabel.text = file.name;
    cell.accessoryType = (file.isDirectory ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone);
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _files.count;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.service.supportsDelete)
        return UITableViewCellEditingStyleDelete;
    return UITableViewCellEditingStyleNone;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ServiceFile *file = _files[indexPath.row];
    if (file.isDirectory)
    {
        FilesViewController *controller = [[FilesViewController alloc] initWithServiceFile:file];
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    
    PrintRequest *req = [[PrintRequest alloc] init];
    req.file = file;
    
    PrintJobTableViewController *controller = [[PrintJobTableViewController alloc] initWithPrintRequest:req];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    nav.navigationBar.translucent = NO;
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nav animated:YES completion:nil];
}

@end
