//
//  PrintJobTableViewController.m
//  BluePrinter
//
//  Created by David Quesada on 2/15/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "PrintJobTableViewController.h"
#import "ChoosePrinterViewController.h"
#import "PrintRequest.h"
#import "ServiceFile.h"
#import "AppDelegate.h"

@interface PrintJobTableViewController ()<ChoosePrinterViewControllerDelegate>
{
    BOOL _canPrint;
}
@property(readwrite) PrintRequest *request;

@property(weak) IBOutlet UITableViewCell *printerCell;
@property(weak) IBOutlet UILabel *copiesLabel;
@property(weak) IBOutlet UIStepper *copiesStepper;
@property(weak) IBOutlet UITableViewCell *printCell;

-(void)updateUI;

@end

@implementation PrintJobTableViewController

-(id)initWithPrintRequest:(PrintRequest *)request
{
    self = [[AppDelegate sharedDelegate].mainStoryboard instantiateViewControllerWithIdentifier:@"printRequestViewController"];
    self.request = request;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.navigationItem.title = self.request.file.name;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)print:(id)sender
{
    if (!_canPrint)
        return;
    
    NSAssert((self.request), @"Print request was null.");
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = @"Printing...";
    [alert show];
    
    [self.request send:^(PrintJob *job, MPrintResponse *response) {
        
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }];
}

-(IBAction)choosePrinter:(id)sender
{
    ChoosePrinterViewController *controller = [[ChoosePrinterViewController alloc] init];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)stepperDidStep:(UIStepper *)stepper
{
    self.request.copies = (int)stepper.value;
    [self updateUI];
}

-(void)updateUI
{
    if (self.request.printLocation)
    {
        self.printerCell.textLabel.textColor = [UIColor blackColor];
        self.printerCell.textLabel.text = self.request.printLocation.displayName;
        self.printerCell.detailTextLabel.text = self.request.printLocation.location;
    } else {
        self.printerCell.textLabel.textColor = [UIColor lightGrayColor];
        self.printerCell.textLabel.text = @"Select a Printer";
        self.printerCell.detailTextLabel.text = nil;
    }
    
    if (self.request.copies == 1)
        _copiesLabel.text = @"1 Copy";
    else
        _copiesLabel.text = [NSString stringWithFormat:@"%d Copies", self.request.copies];
    
    _canPrint = (self.request.printLocation != nil);
    
    if (_canPrint)
    {
        _printCell.selectionStyle = UITableViewCellSelectionStyleDefault;
        _printCell.textLabel.textColor = [UIColor blackColor];
    } else {
        _printCell.selectionStyle = UITableViewCellSelectionStyleNone;
        _printCell.textLabel.textColor = [UIColor lightGrayColor];
    }

}

#pragma mark - ChoosePrinterViewControllerDelegate

-(void)choosePrinterViewController:(ChoosePrinterViewController *)controller didChoosePrintLocation:(Location *)location
{
    self.request.printLocation = location;
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - UITableView Stuff

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell == _printerCell)
        [self choosePrinter:nil];
    else if (cell == _printCell)
        [self print:nil];
}

@end
