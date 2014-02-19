//
//  MPrintCosignManager.h
//  BluePrinter
//
//  Created by David Quesada on 2/17/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const MPrintUserDidLogInNotification;
extern NSString * const MPrintUserDidLogOutNotification;

@interface MPrintCosignManager : NSObject

+(void)userDidLogIn;
+(void)userDidLogOut;

+(BOOL)isPersistentCosignEnabled;
+(void)setPersistentCosignEnabled:(BOOL)enabled;

@end
