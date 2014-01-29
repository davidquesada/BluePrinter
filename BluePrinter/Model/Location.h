//
//  Location.h
//  BluePrinter
//
//  Created by David Paul Quesada on 1/14/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPrintObject.h"

@interface Location : MPrintObject

+(int)locationCount;
+(instancetype)locationAtIndex:(int)index;

+(void)refreshLocations:(void (^)(BOOL success))completion;

@property NSString *name; // Technical name.
@property NSString *displayName;

@property NSString *subCampusArea;
@property NSString *location;

@end
