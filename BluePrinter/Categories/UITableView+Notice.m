//
//  UITableView+Notice.m
//  BluePrinter
//
//  Created by David Quesada on 3/5/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "UITableView+Notice.h"
#import <objc/runtime.h>

#define NOTICE_LABEL_TAG 16500
#define NOTICE_TAIL_TAG 192201

@interface UITableView (NoticePrivate)

@property UIView *actualNoticeView;
-(UIView *)createNoticeView;
-(void)_resizeNoticeView;

@property(readonly, nonatomic, retain) UILabel *noticeLabel;
@property(readonly) UIView *tailView;

@end


@implementation UITableView (Notice)

-(UIView *)noticeView
{
    UIView *v = self.actualNoticeView;
    if (!v)
        self.actualNoticeView = (v = [self createNoticeView]);
    return v;
}

-(UIColor *)noticeTextColor
{
    return self.noticeLabel.textColor;
}

-(void)setNoticeTextColor:(UIColor *)noticeTextColor
{
    self.noticeLabel.textColor = noticeTextColor;
}

-(UIColor *)noticeBackgroundColor
{
    return self.noticeView.backgroundColor;
}

-(void)setNoticeBackgroundColor:(UIColor *)noticeBackgroundColor
{
    self.noticeView.backgroundColor = noticeBackgroundColor;
    self.tailView.backgroundColor = noticeBackgroundColor;
}

-(NSString *)noticeText
{
    return self.noticeLabel.text;
}

-(void)setNoticeText:(NSString *)noticeText
{
    self.noticeLabel.text = noticeText;
    
    if (noticeText)
    {
        self.tableHeaderView = self.noticeView;
        [self _resizeNoticeView];
        
        // This somehow fixes an issue where the space between the
        // UIRefresh control and the notice view would briefly appear
        // as a white sliver while the table view is scrolling.
        self.backgroundView = [UIView new];
    } else
    {
        self.tableHeaderView = nil;
    }
    
    UIColor *newBackgroundColor = (noticeText ? self.noticeBackgroundColor : self.backgroundColor);
    [self.subviews.firstObject setValue:newBackgroundColor forKey:@"backgroundColor"];

    for (UIView *obj in self.subviews)
        if ([obj isKindOfClass:[UIRefreshControl class]])
            [obj setValue:newBackgroundColor forKey:@"backgroundColor"];
}

-(BOOL)isShowingNotice
{
    return !!self.noticeLabel.text;
}

@end

@implementation UITableView (NoticePrivate)

-(UILabel *)noticeLabel
{
    return (UILabel *)[self.noticeView viewWithTag:NOTICE_LABEL_TAG];
}


-(UIView *)actualNoticeView
{
    return objc_getAssociatedObject(self, @selector(actualNoticeView));
}

-(void)setActualNoticeView:(UIView *)actualNoticeView
{
    objc_setAssociatedObject(self, @selector(actualNoticeView), actualNoticeView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)_resizeNoticeView
{
    UIView *_noticeView = self.noticeView;
    UIView *_noticeLabel = self.noticeLabel;
    UIView *_tailView = self.tailView;
    _noticeView.frame = UIEdgeInsetsInsetRect(self.bounds, self.contentInset);
    _noticeLabel.frame = UIEdgeInsetsInsetRect(_noticeView.bounds, UIEdgeInsetsMake(0, 30, _noticeView.bounds.size.height / 4, 30));
    _tailView.frame = CGRectOffset(_noticeView.bounds, 0, _noticeView.bounds.size.height - 2);
}

-(UIView *)createNoticeView
{
    UIView *_noticeView = [[UIView alloc] initWithFrame:CGRectZero];
    _noticeView.clipsToBounds = NO;
    UIView *_noticeTailView = [[UIView alloc] initWithFrame:CGRectZero];
    _noticeTailView.tag = NOTICE_TAIL_TAG;
    [_noticeView addSubview:_noticeTailView];
    
    UILabel *_noticeLabel;
    _noticeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _noticeLabel.tag = NOTICE_LABEL_TAG;
    _noticeLabel.numberOfLines = 0;
    _noticeLabel.font = [UIFont systemFontOfSize:22];
    _noticeLabel.textColor = [UIColor grayColor];
    _noticeLabel.textAlignment = NSTextAlignmentCenter;
    _noticeLabel.backgroundColor = [UIColor clearColor];
    [_noticeView addSubview:_noticeLabel];
    
    _noticeView.backgroundColor = [UIColor colorWithWhite:.9 alpha:1.0];
    _noticeTailView.backgroundColor = _noticeView.backgroundColor;
    
    return _noticeView;
}

-(UIView *)tailView
{
    return [self.noticeView viewWithTag:NOTICE_TAIL_TAG];
}

@end
