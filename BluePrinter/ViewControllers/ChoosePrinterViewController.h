//
//  ChoosePrinterViewController.h
//  BluePrinter
//
//  Created by David Quesada on 2/15/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChoosePrinterViewController;
@class Location;

@protocol ChoosePrinterViewControllerDelegate <NSObject>
@optional
-(void)choosePrinterViewController:(ChoosePrinterViewController *)controller
            didChoosePrintLocation:(Location *)location;
@end

@interface ChoosePrinterViewController : UIViewController
@property(weak) id<ChoosePrinterViewControllerDelegate> delegate;

@end
