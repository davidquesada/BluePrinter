//
//  UserDefaults.h
//  BluePrinter
//
//  Created by David Quesada on 3/21/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrintRequest.h"

@interface UserDefaults : NSObject

+(BOOL)shouldLogOutWhenLeavingApp;

@end


@interface PrintRequest (DefaultOptions)

// Creates a new PrintRequest object with the default options, as specified
// by the user settings.
+(instancetype)printRequestWithDefaultOptions;

@end
