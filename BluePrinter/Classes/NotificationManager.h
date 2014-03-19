//
//  NotificationManager.h
//  BluePrinter
//
//  Created by David Quesada on 3/18/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationManager : NSObject

+(instancetype)defaultNotificationManager;

-(void)applicationWillEnterBackground;
-(void)applicationWillEnterForeground;

@end
