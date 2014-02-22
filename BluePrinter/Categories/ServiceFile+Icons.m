//
//  ServiceFile+Icons.m
//  BluePrinter
//
//  Created by David Quesada on 2/21/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "ServiceFile+Icons.h"

static NSString * const ServiceFileExtensionDirectory = @"/././.";
static NSString * const ServiceFileExtensionGeneric = @"..///..//";

@interface ServiceFile (IconsPrivate)

-(NSDictionary *)imageRepresentationsByExtension;
-(NSString *)imageRepresentationImageName;

@end

@implementation ServiceFile (Icons)

-(UIImage *)imageRepresentationInListView
{
    return [UIImage imageNamed:[self imageRepresentationImageName]];
}

@end

@implementation ServiceFile (IconsPrivate)

-(NSString *)imageRepresentationImageName
{
    static NSDictionary *dict = nil;
    if (!dict)
        dict = [self imageRepresentationsByExtension];
    
    if (self.isDirectory)
        return dict[ServiceFileExtensionDirectory];
    id imgName;
    if ((imgName = dict[self.extension]))
        return imgName;
    return dict[ServiceFileExtensionGeneric];
}

-(NSDictionary *)imageRepresentationsByExtension
{
    // First, build sort of a "reverse" dictionary.
    NSDictionary *generator =
    @{
      @"folder" : @[ ServiceFileExtensionDirectory ],
      @"keynote" : @[ @"key", @"keynote" ],
      @"numbers" : @[ @"numbers" ],
      @"page_white_acrobat" : @[ @"pdf" ],
      @"page_white_actionscript" : @[ @"as" ],
      @"page_white_c" : @[ @"c" ],
      @"page_white_code" : @[ @"asm", @"htm", @"html", @"css", @"bat", @"sh", @"py", @"m", ], // TODO: Get more extensions.
      @"page_white_compressed" : @[ @"zip", @"gz", @"bz", @"7z", @"tar", ],
      @"page_white_cplusplus" : @[ @"cc", @"cxx", @"cpp", ],
      @"page_white_csharp" : @[ @"cs" ],
      @"page_white_cup" : @[ @"java" ],
      @"page_white_dvd" : @[ @"iso" ],
      @"page_white_excel" : @[ @"xls", @"xlsx" ],
      @"page_white_film" : @[ @"mp4", @"mov", @"avi", @"flv", @"mkv", @"mpg", @"3g2", @"3gp", @"asf", @"asx", @"m4v", @"wmv", ],
      @"page_white_flash" : @[ @"swf" ],
      @"page_white_gear" : @[ @"ini", @"inf", @"conf", @"db", ],
      @"page_white_h" : @[ @"h", @"hpp", @"hxx", ],
      @"page_white_js" : @[ @"js" ],
      @"page_white_paint" : @[ @"psd", @"pdd", ],
      @"page_white_php" : @[ @"php" ],
      @"page_white_picture" : @[ @"png", @"jpg", @"jpeg", @"bmp", @"gif", @"tga", @"tif", @"tiff", ],
      @"page_white_powerpoint" : @[ @"ppt", @"pptx", ],
      @"page_white_ruby" : @[ @"rb" ],
      @"page_white_sound" : @[ @"wav", @"mp3", @"mid", @"ogg", @"aif", @"m3u", @"m4a", @"wma", ],
      @"page_white_text" : @[ @"txt", @"text", @"csv", ],
      @"page_white_tux" : @[],
      @"page_white_vector" : @[ @"ai" ],
      @"page_white_visualstudio" : @[ @"sln", @"csproj", @"cproj", @"vbproj", ],
      @"page_white_word" : @[ @"doc", @"docx", @"docm", ],
      @"page_white" : @[ ServiceFileExtensionGeneric ],
      @"pages" : @[ @"pages" ],
      };
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [generator enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        for (NSString *ext in obj)
            dict[ext] = key;
    }];
    
    return dict;
}

@end