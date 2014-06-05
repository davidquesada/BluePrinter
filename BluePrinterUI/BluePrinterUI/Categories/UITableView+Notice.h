//
//  UITableView+Notice.h
//  BluePrinterUI
//
//  Created by David Quesada on 3/5/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (Notice)

@property(readonly, nonatomic, retain) UIView *noticeView;
@property(nonatomic) UIColor *noticeTextColor;
@property(nonatomic) UIColor *noticeBackgroundColor;
@property(nonatomic) NSString *noticeText;
@property(readonly) BOOL isShowingNotice;

//@property(readonly) NSMutableArray *viewsTo

@end
