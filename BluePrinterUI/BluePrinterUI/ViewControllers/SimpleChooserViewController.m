//
//  SimpleChooserViewController.m
//  BluePrinterUI
//
//  Created by David Quesada on 2/17/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "SimpleChooserViewController.h"

@interface SimpleChooserCell : UITableViewCell
@end

@interface SimpleChooserViewController ()

@property NSInteger selectedIndex;
@property NSArray *options;

@end

@implementation SimpleChooserViewController

-(id)initWithTitle:(NSString *)title options:(NSArray *)options selectedIndex:(NSInteger)index
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.navigationItem.title = title;
        self.options = options;
        self.selectedIndex = index;
    }
    return self;
}

-(id)initWithTitle:(NSString *)title options:(NSArray *)options selectedString:(NSString *)string
{
    NSInteger index = (NSInteger)[options indexOfObject:string];
    return self = [self initWithTitle:title options:options selectedIndex:index];
}

-(id)initWithTitle:(NSString *)title options:(NSArray *)options
{
    return self = [self initWithTitle:title options:options selectedIndex:-1];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[SimpleChooserCell class] forCellReuseIdentifier:@"s"];
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.options.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"s" forIndexPath:indexPath];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"s"];
    
    cell.textLabel.text = _options[indexPath.row];
    cell.accessoryType = (indexPath.row == _selectedIndex ? UITableViewCellAccessoryCheckmark :UITableViewCellAccessoryNone);
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSString *item = _options[row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.delegate respondsToSelector:@selector(simpleChooser:didChooseItem:atIndex:)])
        [self.delegate simpleChooser:self didChooseItem:item atIndex:row];
    [self.navigationController popViewControllerAnimated:YES];
}

@end

@implementation SimpleChooserCell

- (id)init
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"s"];
    if (self) {
        
    }
    return self;
}

@end
