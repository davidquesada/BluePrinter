//
//  LoginViewController.h
//  BluePrinter
//
//  Created by David Quesada on 1/17/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginViewController;
@protocol LoginViewControllerDelegate <NSObject>
@optional
-(void)loginViewController:(LoginViewController *)controller willDismissWithLoginResult:(BOOL)loggedIn;
-(void)loginViewController:(LoginViewController *)controller didDismissWithLoginResult:(BOOL)loggedIn;
@end

@interface LoginViewController : UINavigationController

@property(weak, nonatomic) id<UINavigationControllerDelegate, LoginViewControllerDelegate> delegate;

@end
