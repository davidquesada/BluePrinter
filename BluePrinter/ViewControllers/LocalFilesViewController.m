//
//  LocalFilesViewController.m
//  BluePrinter
//
//  Created by David Quesada on 3/5/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "LocalFilesViewController.h"
#import "SVProgressHUD.h"

@interface LocalFilesViewController ()<UITableViewDelegate>
{
    UIBarButtonItem *deleteButton;
}
@end

@implementation LocalFilesViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    UITableView *tableView = [self valueForKey:@"tableView"];
    tableView.noticeBackgroundColor = [UIColor whiteColor];
    
    deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(delete:)];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    tableView.allowsSelectionDuringEditing = YES;
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    UITableView *tableView = [self valueForKey:@"tableView"];
    
    // http://stackoverflow.com/questions/9683516
    tableView.allowsMultipleSelectionDuringEditing = editing;
    
    [super setEditing:editing animated:animated];
    [tableView setEditing:editing animated:animated];
    
    deleteButton.enabled = !!tableView.indexPathsForSelectedRows.count;
    [deleteButton setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor redColor] } forState:UIControlStateNormal];
    [deleteButton setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor grayColor] } forState:UIControlStateDisabled];
    
    if (editing)
        [self.navigationItem setLeftBarButtonItem:deleteButton animated:animated];
    else
        [self.navigationItem setLeftBarButtonItem:nil animated:animated];
}

-(NSString *)noticeTextForEmptyFolder
{
    return @"Files you import from other apps will be saved here.";
}
                    
-(void)delete:(id)sender
{
    deleteButton.enabled = NO;
    NSMutableArray *files = [self valueForKey:@"files"];
    NSMutableIndexSet *set = [[NSMutableIndexSet alloc] init];
    UITableView *tableView = [self valueForKey:@"tableView"];
    for (NSIndexPath *ip in tableView.indexPathsForSelectedRows)
        [set addIndex:ip.row];
    
    [SVProgressHUD show];
    
    NSArray *targets = [files objectsAtIndexes:set];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int total = targets.count;
        int count = 0;
        
        for (ServiceFile *file in targets)
        {
            [file deleteBlocking];
            ++count;
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showProgress:((float)count / total)];
            });
        }

        [self performSelectorOnMainThread:@selector(animateDeleteSelectedFiles:) withObject:set waitUntilDone:YES];
    });
}

-(void)animateDeleteSelectedFiles:(NSIndexSet *)set
{
    [SVProgressHUD dismiss];
    
    NSMutableArray *files = [self valueForKey:@"files"];
    UITableView *tableView = [self valueForKey:@"tableView"];
    if (set.count == files.count)
    {
        [files removeAllObjects];
        [tableView reloadData];
        [self setEditing:NO animated:NO];
        tableView.noticeText = [self noticeTextForEmptyFolder];
        [tableView reloadData];
    }
    else
    {
        [files removeObjectsAtIndexes:set];
        [tableView deleteRowsAtIndexPaths:tableView.indexPathsForSelectedRows withRowAnimation:UITableViewRowAnimationLeft];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UITableViewDataSource/Delegate Methods

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    deleteButton.enabled = !!tableView.indexPathsForSelectedRows.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    deleteButton.enabled = !!tableView.indexPathsForSelectedRows.count;
}

@end
