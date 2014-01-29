//
//  Service.h
//  BluePrinter
//
//  Created by David Quesada on 1/29/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MPrintObject.h"

@interface Service : MPrintObject

@property (readonly) NSString *description;
@property (readonly) BOOL isConnected;
@property (readonly) NSString *name;

-(void)fetchDirectoryInfoForPath:(NSString *)path completion:(MPrintFetchHandler)completion;

@end
