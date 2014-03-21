//
//  UserDefaults.h
//  BluePrinter
//
//  Created by David Quesada on 3/21/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrintRequest.h"


typedef NS_ENUM(NSInteger, ImportAction)
{
    ImportActionNone,
    ImportActionPrintSometimes,
    ImportActionPrintAlways,
};


@interface UserDefaults : NSObject

+(BOOL)shouldLogOutWhenLeavingApp;
+(BOOL)shouldSaveImportedFiles;
+(ImportAction)importAction;

@end


@interface PrintRequest (DefaultOptions)

// Creates a new PrintRequest object with the default options, as specified
// by the user settings.
+(instancetype)printRequestWithDefaultOptions;
-(void)loadDefaultOptions;

@end
