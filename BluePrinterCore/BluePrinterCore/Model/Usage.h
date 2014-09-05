//
//  Usage.h
//  BluePrinterCore
//
//  Created by David Quesada on 3/3/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MPrintObject.h"

typedef NS_ENUM(NSInteger, UsageType)
{
    UsageTypeBlackAndWhite,
    UsageTypeColor,
    UsageTypeTabloid,
};

@interface Usage : MPrintObject

@property(readonly) double balance;
@property(readonly) int totalJobs;
@property(readonly) int totalPages;
@property(readonly) int totalSheets;

+(NSString *)costDescriptionForUsageType:(UsageType)type;
+(double)costForUsageType:(UsageType)type;

-(int)estimatedRemainingUsagesOfType:(UsageType)type;

@end
