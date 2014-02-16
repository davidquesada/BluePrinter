//
//  PrintRequest.h
//  BluePrinter
//
//  Created by David Quesada on 2/11/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ServiceFile;
@class Location;
@class PrintJob;
@class MPrintResponse;

@interface PrintRequest : NSObject

@property ServiceFile *file;
@property NSInteger copies;
@property Location *printLocation;

-(void)send:(void (^)(PrintJob *job, MPrintResponse *response))completion;

@end
