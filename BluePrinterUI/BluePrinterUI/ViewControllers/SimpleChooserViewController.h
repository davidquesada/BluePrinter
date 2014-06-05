//
//  SimpleChooserViewController.h
//  BluePrinterUI
//
//  Created by David Quesada on 2/17/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SimpleChooserViewController;
@protocol SimpleChooserViewControllerDelegate <NSObject>
@optional
-(void)simpleChooser:(SimpleChooserViewController *)chooser didChooseItem:(NSString *)item atIndex:(NSInteger)index;
@end

@interface SimpleChooserViewController : UITableViewController

@property(weak) id<SimpleChooserViewControllerDelegate> delegate;

-(id)initWithTitle:(NSString *)title options:(NSArray *)options;
-(id)initWithTitle:(NSString *)title options:(NSArray *)options selectedIndex:(NSInteger)index;
-(id)initWithTitle:(NSString *)title options:(NSArray *)options selectedString:(NSString *)string;

@end
