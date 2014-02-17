//
//  MPrintCosignManager.h
//  BluePrinter
//
//  Created by David Quesada on 2/17/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPrintCosignManager : NSObject

+(void)didLogIn;
+(void)didLogOut;

+(BOOL)isPersistentCosignEnabled;
+(void)setPersistentCosignEnabled:(BOOL)enabled;

@end
