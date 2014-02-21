//
//  MPrintDriveService.m
//  BluePrinter
//
//  Created by David Quesada on 2/20/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "MPrintDriveService.h"

@implementation MPrintDriveService

-(NSString *)name
{
    return @"drive";
}

-(NSString *)description
{
    return @"Google Drive";
}

-(NSString *)preparePathForDirectory:(NSString *)directory
{
    // For some reason, the Google Drive service doesn't like / as a path.
    if ([directory isEqualToString:@"/"])
        return @"";
    return directory;
}

@end
