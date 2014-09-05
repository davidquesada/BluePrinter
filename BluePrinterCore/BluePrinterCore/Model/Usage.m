//
//  Usage.m
//  BluePrinterCore
//
//  Created by David Quesada on 3/3/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "Usage.h"

@implementation Usage

+(NSString *)fetchAPIEndpoint
{
    return [NSString stringWithFormat:@"/users?accounts"];
}

-(instancetype)initWithJSONDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self)
    {
        NSDictionary *accountsDict = dictionary[@"accounts"];
//        NSDictionary *acctDict = accountsDict[@"euc"];
        NSDictionary *acct = [[accountsDict allValues] lastObject];
        
        if (!acct)
            return nil;
        
        NSLog(@"WOO");
        
        id boxedBalance = [acct[@"personal"] lastObject][@"balance"];
        _balance = [boxedBalance doubleValue];
        
        id boxedJobs = acct[@"stats"][@"total_jobs"];
        _totalJobs = [boxedJobs doubleValue];
        
        id boxedSheets = acct[@"stats"][@"total_sheets"];
        _totalSheets = [boxedSheets doubleValue];
        
        id boxedPages = acct[@"stats"][@"total_pages"];
        _totalPages = [boxedPages doubleValue];
    }
    return self;
}

+(NSString *)costDescriptionForUsageType:(UsageType)type
{
    if (type == UsageTypeBlackAndWhite)
        return @"6¢ / page";
    if (type == UsageTypeColor)
        return @"23¢ / page";
    if (type == UsageTypeTabloid)
        return @"46¢ / page";
    return nil;
}

+(double)costForUsageType:(UsageType)type
{
    if (type == UsageTypeBlackAndWhite)
        return 0.06;
    if (type == UsageTypeColor)
        return 0.23;
    if (type == UsageTypeTabloid)
        return 0.46;
    return 0.0;
}

-(int)estimatedRemainingUsagesOfType:(UsageType)type
{
    if (_balance < 0)
        return 0;
    return _balance / [self.class costForUsageType:type];
}

@end
