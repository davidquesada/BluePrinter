//
//  MPrintNetworkedService.h
//  BluePrinter
//
//  Created by dquesada on 2/20/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "Service.h"

@interface MPrintNetworkedService : Service

-(NSString *)preparePathForDirectory:(NSString *)directory;

@end
