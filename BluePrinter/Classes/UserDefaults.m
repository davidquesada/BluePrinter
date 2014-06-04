//
//  UserDefaults.m
//  BluePrinter
//
//  Created by David Quesada on 3/21/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "UserDefaults.h"

#define MAKE_DICTIONARY(identifier,contents)\
static NSDictionary *identifier = nil;\
if (!identifier)\
    identifier = contents;

static NSString * const DefaultOrientationKey = @"DefaultOrientation";
static NSString * const DefaultPagesPerSheetKey = @"DefaultPagesPerSheet";
static NSString * const DefaultDoubleSidedKey = @"DefaultDoubleSided";
static NSString * const DefaultFitToPageKey = @"DefaultFitToPage";

static NSString * const DefaultShouldLogOutWhenLeavingAppKey = @"DefaultLogoutOnBackground";
static NSString * const DefaultShouldSaveImportedFilesKey = @"DefaultSaveImportedFiles";
static NSString * const DefaultImportActionKey = @"DefaultImportAction";

@interface UserDefaults ()

+(id)valueForUserDefault:(NSString *)key;

+(MPOrientation)defaultOrientation;
+(NSInteger)defaultPagesPerSheet;
+(MPDoubleSided)defaultDoubleSided;
+(BOOL)defaultFitToPage;

@end

@implementation UserDefaults

+(id)valueForUserDefault:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

+(MPOrientation)defaultOrientation
{
    MAKE_DICTIONARY(dict, (@{ @"MPOrientationPortrait" : @(MPOrientationPortrait),
                             @"MPOrientationLandscape" : @(MPOrientationLandscape), }));
    id val = [self valueForUserDefault:DefaultOrientationKey];
    if ((val = [dict valueForKey:val]))
        return (MPOrientation)[val integerValue];
    return MPOrientationPortrait;
}

+(NSInteger)defaultPagesPerSheet
{
    static NSSet *acceptableValues = nil;
    if (!acceptableValues)
        acceptableValues = [NSSet setWithObjects:@(1), @(2), @(4), @(6), @(9), @(16), nil];
    
    id val = [self valueForUserDefault:DefaultPagesPerSheetKey];
    if (![val respondsToSelector:@selector(integerValue)])
        return 1;
    if (![acceptableValues containsObject:val])
        return 1;
    return [val integerValue];
}

+(MPDoubleSided)defaultDoubleSided
{
    MAKE_DICTIONARY(dict, (@{ @"MPDoubleSidedNo" : @(MPDoubleSidedNo),
                              @"MPDoubleSidedShortEdge" : @(MPDoubleSidedShortEdge),
                              @"MPDoubleSidedLongEdge" : @(MPDoubleSidedLongEdge), }));
    id val = [self valueForUserDefault:DefaultDoubleSidedKey];
    if ((val = [dict valueForKey:val]))
        return (MPDoubleSided)[val integerValue];
    return MPDoubleSidedNo;
}

+(BOOL)defaultFitToPage
{
    id val = [self valueForUserDefault:DefaultFitToPageKey];
    if (![val respondsToSelector:@selector(boolValue)])
        return YES;
    return [val boolValue];
}


+(BOOL)shouldLogOutWhenLeavingApp
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:DefaultShouldLogOutWhenLeavingAppKey];
}

+(BOOL)shouldSaveImportedFiles
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:DefaultShouldSaveImportedFilesKey])
        return [[NSUserDefaults standardUserDefaults] boolForKey:DefaultShouldSaveImportedFilesKey];
    return YES;
}

+(ImportAction)importAction
{
    MAKE_DICTIONARY(dict, (@{ @"MPImportActionNothing" : @(ImportActionNone),
                              @"MPImportActionPrintIfLoggedIn" : @(ImportActionPrintSometimes),
                              @"MPImportActionPrint" : @(ImportActionPrintAlways) }));
    id val = [self valueForUserDefault:DefaultImportActionKey];
    if ((val = dict[val]))
        return (ImportAction)[val integerValue];
    return ImportActionPrintAlways;
}

@end


@implementation PrintRequest (DefaultOptions)

+(instancetype)printRequestWithDefaultOptions
{
    PrintRequest *req = [[self alloc] init];
    [req loadDefaultOptions];
    return req;
}

-(void)loadDefaultOptions
{
    self.orientation = [UserDefaults defaultOrientation];
    self.pagesPerSheet = [UserDefaults defaultPagesPerSheet];
    self.doubleSided = [UserDefaults defaultDoubleSided];
    self.fitToPage = [UserDefaults defaultFitToPage];
}

@end
