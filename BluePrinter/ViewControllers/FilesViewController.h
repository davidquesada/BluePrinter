//
//  FilesViewController.h
//  BluePrinter
//
//  Created by David Paul Quesada on 1/14/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Service;

@interface FilesViewController : UIViewController

-(id)initWithService:(Service *)service;
-(id)initWithService:(Service *)service path:(NSString *)path;

@property(readonly) Service *service;
@property(readonly) NSString *path;

@end
