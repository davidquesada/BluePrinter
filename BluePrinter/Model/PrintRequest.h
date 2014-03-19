//
//  PrintRequest.h
//  BluePrinter
//
//  Created by David Quesada on 2/11/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Location.h"
#import "ServiceFile.h"

@class PrintJob;
@class MPrintResponse;

typedef NS_ENUM(NSInteger, MPOrientation)
{
    MPOrientationPortrait,
    MPOrientationLandscape,
};

typedef NS_ENUM(NSInteger, MPDoubleSided)
{
    MPDoubleSidedNo,
    MPDoubleSidedLongEdge,
    MPDoubleSidedShortEdge,
};

// This notification is posted after a print request returns, after any immediate completion handler.
extern NSString * const PrintRequestDidSendNotification;

// The PrintRequest object that originally send the request.
extern NSString * const PrintRequestUserInfoKey;

// The MPrintResponse object that was returned from sending the PrintRequest object.
extern NSString * const PrintRequestResponseUserInfoKey;


@interface PrintRequest : NSObject

@property ServiceFile *file;
@property Location *printLocation;

@property NSInteger copies;
@property MPOrientation orientation;
@property NSInteger pagesPerSheet;
@property MPDoubleSided doubleSided;

@property BOOL fitToPage;

@property(copy) NSString *pageRange;

-(void)send:(void (^)(PrintJob *job, MPrintResponse *response))completion;

@end

@interface PrintRequest (Descriptions)

-(NSString *)orientationDescription;
-(NSString *)doubleSidedDescription;

@end