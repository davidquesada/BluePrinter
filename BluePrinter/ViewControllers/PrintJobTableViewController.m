//
//  PrintJobTableViewController.m
//  BluePrinter
//
//  Created by David Quesada on 2/15/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "PrintJobTableViewController.h"
#import "ChoosePrinterViewController.h"
#import "SimpleChooserViewController.h"
#import "PrintRequest.h"
#import "ServiceFile.h"
#import "AppDelegate.h"

@interface PrintJobTableViewController ()<ChoosePrinterViewControllerDelegate, SimpleChooserViewControllerDelegate>
{
    BOOL _canPrint;
    __weak SimpleChooserViewController *orientationChooser;
    __weak SimpleChooserViewController *pagesChooser;
    __weak SimpleChooserViewController *doubleSidedChooser;
}
@property(readwrite) PrintRequest *request;

@property(weak) IBOutlet UITableViewCell *printerCell;
@property(weak) IBOutlet UILabel *copiesLabel;
@property(weak) IBOutlet UIStepper *copiesStepper;
@property(weak) IBOutlet UITextField *rangeTextField;
@property(weak) IBOutlet UISwitch *scaleSwitch;

@property(weak) IBOutlet UITableViewCell *printCell;

@property(weak) IBOutlet UITableViewCell *orientationCell;
@property(weak) IBOutlet UITableViewCell *pagesPerSheetCell;
@property(weak) IBOutlet UITableViewCell *doubleSidedCell;

-(void)updateUI;
-(void)showChooserForTriggeringCell:(UITableViewCell *)cell;

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
    self.actuallyDeselectRowOnViewWillAppear = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUI];
}

-(void)print:(id)sender
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

-(void)choosePrinter:(id)sender
{
    ChoosePrinterViewController *controller = [[ChoosePrinterViewController alloc] init];
    controller.delegate = self;
    controller.selectedLocation = self.request.printLocation;
    [self.navigationController pushViewController:controller animated:YES];
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
    
    _rangeTextField.text = self.request.pageRange;
    
    _canPrint = (self.request.printLocation != nil);
    
    _orientationCell.detailTextLabel.text = [self.request orientationDescription];
    _pagesPerSheetCell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.request.pagesPerSheet];
    _doubleSidedCell.detailTextLabel.text = [self.request doubleSidedDescription];
    _scaleSwitch.on = self.request.fitToPage;
    
    if (_canPrint)
    {
        _printCell.selectionStyle = UITableViewCellSelectionStyleDefault;
        _printCell.textLabel.textColor = [UIColor blackColor];
    } else {
        _printCell.selectionStyle = UITableViewCellSelectionStyleNone;
        _printCell.textLabel.textColor = [UIColor lightGrayColor];
    }

}

-(void)showChooserForTriggeringCell:(UITableViewCell *)cell
{
    SimpleChooserViewController *chooser = nil;
    if (cell == self.orientationCell)
    {
        chooser = [[SimpleChooserViewController alloc] initWithTitle:@"Orientation" options:@[ @"Portrait", @"Landscape" ] selectedString:self.orientationCell.detailTextLabel.text];
        orientationChooser = chooser;
    } else if (cell == self.pagesPerSheetCell)
    {
        chooser = [[SimpleChooserViewController alloc] initWithTitle:@"Pages Per Sheet" options:@[ @"1", @"2", @"4", @"6", @"9", @"16" ] selectedString:self.pagesPerSheetCell.detailTextLabel.text];
        pagesChooser = chooser;
    } else if (cell == self.doubleSidedCell)
    {
        chooser = [[SimpleChooserViewController alloc] initWithTitle:@"Double-Sided" options:@[ @"No", @"Bind on long edge", @"Bind on short edge"] selectedString:self.doubleSidedCell.detailTextLabel.text];
        doubleSidedChooser = chooser;
    }
    
    if (!chooser)
        return;
    
    chooser.delegate = self;
    [self.navigationController pushViewController:chooser animated:YES];
}

#pragma mark - IBActions

-(IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)stepperDidStep:(UIStepper *)stepper
{
    // Calling [self updateUI] nukes any changes the user makes to "range" if the field is still being edited.
    // As a hack, just stop editing the "range" field so its value is saved.
    [_rangeTextField resignFirstResponder];
    
    self.request.copies = (int)stepper.value;
    [self updateUI];
}

-(IBAction)pageRangeDidChange:(id)sender
{
    self.request.pageRange = _rangeTextField.text;
}

-(IBAction)scaleSwitchDidChange:(id)sender
{
    self.request.fitToPage = _scaleSwitch.on;
}

#pragma mark - SimpleChooserViewControllerDelegate Methods

-(void)simpleChooser:(SimpleChooserViewController *)chooser didChooseItem:(NSString *)item atIndex:(NSInteger)index
{
    if (chooser == orientationChooser)
    {
        self.request.orientation = (index ? MPOrientationLandscape : MPOrientationPortrait);
    }
    else if (chooser == pagesChooser)
    {
        self.request.pagesPerSheet = [@[@1, @2, @4, @6, @9, @16][index] integerValue];;
    }
    else if (chooser == doubleSidedChooser)
    {
        switch (index)
        {
            case 0: self.request.doubleSided = MPDoubleSidedNo; break;
            case 1: self.request.doubleSided = MPDoubleSidedLongEdge; break;
            case 2: self.request.doubleSided = MPDoubleSidedShortEdge; break;
        }
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
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    if (cell == _printerCell)
        [self choosePrinter:nil];
    else if (cell == _printCell)
    {
        [self print:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
        [self showChooserForTriggeringCell:cell];
}

@end
