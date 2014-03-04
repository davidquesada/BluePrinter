//
//  Usage.h
//  BluePrinter
//
//  Created by David Quesada on 3/3/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MPrintObject.h"

#import "UsageAllocation.h"
#import "UsageCategory.h"

@interface Usage : MPrintObject

@property(readonly) NSArray *categories;

@end
