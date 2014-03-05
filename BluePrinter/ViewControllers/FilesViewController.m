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

@property NSMutableArray *files;

@property(weak) UITableView *tableView;
@property(weak) UIRefreshControl *refresh;

-(void)insertFile:(ServiceFile *)file atIndex:(NSInteger)index;
-(NSInteger)indexToInsertFile:(ServiceFile *)file;

-(void)didImportFile:(NSNotification *)note;
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
    self.refresh = ref;
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
    if (_service.supportsImport)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didImportFile:) name:MPrintDidImportFileNotification object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        
        self.files = objects;
        [self.refresh endRefreshing];
        [self.tableView reloadData];
    }];
}

-(void)updateFooter
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:1];
    [self.tableView reloadRowsAtIndexPaths:@[ path ] withRowAnimation:UITableViewRowAnimationFade];
}

-(NSInteger)indexToInsertFile:(ServiceFile *)file
{
    // Don't count the _footerObject at the end.
    NSRange range = NSMakeRange(0, self.files.count);
    
    NSInteger index = [self.files indexOfObject:file inSortedRange:range options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(ServiceFile *obj1, ServiceFile *obj2) {
        return [obj1.name compare:obj2.name];
    }];
    return index;
}

-(void)insertFile:(ServiceFile *)file atIndex:(NSInteger)index
{
    if (!file)
    {
        NSLog(@"File must be non-nil for inserting");
        return;
    }
    if (index == NSNotFound)
    {
        NSLog(@"Index must be a valid index");
        return;
    }
    
    [self.files insertObject:file atIndex:index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    });
    
    [self updateFooter];
}

#pragma mark - Notification Handlers

-(void)didImportFile:(NSNotification *)note
{
    ServiceFile *file = note.object;
    
    // If the service wasn't able to generate a ServiceFile record upon import, we should
    // refresh the view, just in case we imported the file into the current directory.
    if (!file)
    {
        [self refresh:nil];
        return;
    }
    
    NSLog(@"Woop");
    
    double delayInSeconds = 0.75;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSInteger index = [self indexToInsertFile:file];
        [self insertFile:file atIndex:index];
    });
}

#pragma mark - UITableView Stuff

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"footerCell"];
        NSInteger count = self.files.count;
        if (count < 1)
            cell.textLabel.text = @"No Files";
        else if (count == 1)
            cell.textLabel.text = @"1 File";
        else
            cell.textLabel.text = [NSString stringWithFormat:@"%d Files", count];
        return cell;
    }
    
    ServiceFile *file = _files[indexPath.row];
    
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
        return 1;
    return _files.count;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
        return UITableViewCellEditingStyleNone;
    
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
    
    if (indexPath.section == 1)
        return;
    
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
