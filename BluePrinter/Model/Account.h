//
//  Account.h
//  BluePrinter
//
//  Created by David Quesada on 1/16/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Account : NSObject

// TODO: make a cached-ish way to access this.
+(void)checkLoginStatus:(void (^)(BOOL isLoggedIn))completion;
+(void)logout:(void (^)(BOOL success))completion;

+(Account *)main;



@property(readonly) NSString *username;

@end
