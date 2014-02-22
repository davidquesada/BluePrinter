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
    NSObject *_footerObject;
}
@property(readwrite) Service *service;
@property(readwrite) NSString *path;

@property NSMutableArray *files;

@property(weak) UITableView *tableView;
@property(weak) UIRefreshControl *refresh;

-(void)updateFooter;
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
    [self.tableView registerNib:[UINib nibWithNibName:@"DirectoryCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"directoryCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FooterCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"footerCell"];
    
    UIRefreshControl *ref = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:ref];
    [ref addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    if (![self.path isEqualToString:@"/"])
        self.navigationItem.title = [self.path lastPathComponent];
    else
        self.navigationItem.title = self.service.description;
    
    _footerObject = [NSObject new];
    self.files = @[ _footerObject ].mutableCopy;
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.service fetchDirectoryInfoForPath:self.path completion:^(NSMutableArray *objects, MPrintResponse *response) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        [objects addObject:_footerObject];
        self.files = objects;
        [sender endRefreshing];
        [self.tableView reloadData];
    }];
}

-(void)updateFooter
{
    NSIndexPath *last = self.tableView.indexPathsForVisibleRows.lastObject;
    if ((_files[last.row] != _footerObject) || !last)
        return;
    [self.tableView reloadRowsAtIndexPaths:@[ last ] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableView Stuff

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServiceFile *file = _files[indexPath.row];
    if (file == (id)_footerObject)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"footerCell"];
        NSInteger count = self.files.count - 1;
        if (count < 1)
            cell.textLabel.text = @"No Files";
        else if (count == 1)
            cell.textLabel.text = @"1 File";
        else
            cell.textLabel.text = [NSString stringWithFormat:@"%d Files", count];
        return cell;
    }
    
    
    BOOL isDir = file.isDirectory;
    static NSDateFormatter *formatter = nil;
    
    if (!formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterLongStyle;
    }
    
    UITableViewCell *cell;
    if (!isDir)
        cell = [tableView dequeueReusableCellWithIdentifier:@"fileCell"];
    else
        cell = [tableView dequeueReusableCellWithIdentifier:@"directoryCell"];
    
    cell.imageView.image = [file imageRepresentationInListView];
    cell.textLabel.text = file.name;
    
    if (!isDir)
    {
        NSDate *moddate = file.modifiedDate;
        if (moddate)
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Modified %@", [formatter stringFromDate:moddate]];
        }
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _files.count;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServiceFile *file = self.files[indexPath.row];
    if ([file isKindOfClass:[ServiceFile class]] && file.isDeletable)
        return UITableViewCellEditingStyleDelete;
    return UITableViewCellEditingStyleNone;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServiceFile *file = self.files[indexPath.row];
    NSAssert([file isKindOfClass:[ServiceFile class]], @"Attempting to delete a file that is not a ServiceFile.");
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [file deleteWithCompletion:^(BOOL wasDeleted) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (wasDeleted)
        {
            [self.files removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self updateFooter];
        }
        else
            [self.tableView setEditing:NO animated:YES];
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ServiceFile *file = _files[indexPath.row];
    
    if (file == (id)_footerObject)
        return;
    
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
