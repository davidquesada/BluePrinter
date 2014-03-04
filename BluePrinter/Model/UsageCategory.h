//
//  UsageCategory.h
//  BluePrinter
//
//  Created by David Quesada on 3/3/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MPrintObject.h"

@interface UsageCategory : MPrintObject

@property(readonly) NSString *name;
@property(readonly) NSString *unit;
@property(readonly) NSInteger totalUsage;
@property(readonly) NSInteger totalAllocation;
@property(readonly) NSArray *allocations;

@end
