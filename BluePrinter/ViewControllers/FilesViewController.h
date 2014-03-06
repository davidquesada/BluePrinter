//
//  FilesViewController.h
//  BluePrinter
//
//  Created by David Paul Quesada on 1/14/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Service;
@class ServiceFile;

@interface FilesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

-(id)initWithService:(Service *)service;
-(id)initWithService:(Service *)service path:(NSString *)path;
-(id)initWithServiceFile:(ServiceFile *)file;

@property(readonly) Service *service;
@property(readonly) NSString *path;

@end
