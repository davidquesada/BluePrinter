//
//  MPrintServiceAuthenticationViewController.h
//  BluePrinter
//
//  Created by David Quesada on 2/22/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPrintServiceAuthenticationViewController;
@class MPrintNetworkedService;

@protocol MPrintServiceAuthenticationViewControllerDelegate <UINavigationControllerDelegate>
@optional
-(void)authenticationController:(MPrintServiceAuthenticationViewController *)controller
willDismissWithAuthenticationStatus:(BOOL)authenticated;
@end

@interface MPrintServiceAuthenticationViewController : UINavigationController

@property(weak, nonatomic) id<MPrintServiceAuthenticationViewControllerDelegate> delegate;

-(id)initWithURL:(NSURL *)url service:(MPrintNetworkedService *)service;

@end
