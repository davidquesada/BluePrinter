//
//  PrintRequest.m
//  BluePrinter
//
//  Created by David Quesada on 2/11/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "PrintRequest.h"
#import "ServiceFile.h"
#import "Service.h"
#import "MPrintRequest.h"
#import "MPrintResponse.h"

@implementation PrintRequest

-(void)send:(void (^)(PrintJob *, MPrintResponse *))completion
{
//    MPrintRequest *req = [[MPrintRequest alloc] initWithEndpoint:@"/jobs" method:POST];
}

@end
