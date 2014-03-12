//
//  ServiceFile+FileTypes.m
//  BluePrinter
//
//  Created by David Quesada on 3/12/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "ServiceFile+FileTypes.h"

static NSSet *extensions = nil;

@implementation ServiceFile (FileTypes)

-(BOOL)isPrintingSupportedForFileType
{
    if (!extensions)
        extensions = [NSSet setWithArray:@[
                                           @"ai", @"bmp", @"c", @"cpp", @"csv", @"doc", @"docx", @"eps", @"gif", @"h", @"ico", @"jp2", @"jpeg", @"jpg", @"m", @"odf", @"pdf", @"php", @"png", @"pps", @"ppsx", @"ppt", @"pptx", @"ps", @"psd", @"py", @"rtf", @"tif", @"tiff", @"txt", @"xls", @"xlsx", @"xml", @"xps",
                                           ]];
    
    NSString *ext = self.extension.lowercaseString;
    if (!ext.length)
        return NO;
    return [extensions containsObject:ext];
}

@end
