//
//  UsageAllocation.h
//  BluePrinterCore
//
//  Created by David Quesada on 3/3/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MPrintObject.h"

@interface UsageAllocation : MPrintObject

@property(readonly) NSString *name;
@property(readonly) NSInteger allocation;

-(id)initWithName:(NSString *)name allocation:(NSInteger)allocation;

@end
