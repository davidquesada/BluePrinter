//
//  LegacySupport.m
//  BluePrinter
//
//  Created by David Quesada on 3/24/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "LegacySupport.h"
#import <objc/runtime.h>

#pragma mark - Private Interface

@interface LegacySupport ()
+(void)install;
@end

#pragma mark - Hook Declarations

id new__NSArray_firstObject(id self, SEL cmd);

id new__UIView_tintColor(UIView *self, SEL cmd);
void new__UIView_setTintColor(UIView *self, SEL cmd, UIColor *color);

id new__UIToolbar_barTintColor(id self, SEL cmd);
void new__UIToolbar_setBarTintColor(id self, SEL cmd, UIColor *color);

UIEdgeInsets new__UITableViewCell_separatorInset(id self, SEL cmd);
void new__UITableViewCell_setSeparatorInset(id self, SEL cmd, UIEdgeInsets insets);

void new__UIViewController_setAutomaticallyAdjustsScrollViewInsets(id self, SEL cmd, BOOL woo);

UIColor *new__UINavigationBar_barTintColor(id self, SEL cmd);
void new__UINavigationBar_setBarTintColor(id self, SEL cmd, UIColor *color);

UIColor *new__UILabel_highlightedTextColor(id self, SEL cmd);

#pragma mark - Hooking Logic

@implementation LegacySupport

+(void)installIfNeeded
{
    if ([[[UIDevice currentDevice] systemVersion] integerValue] < 7)
        [self install];
}

+(void)install
{
    static BOOL installed = NO;
    if (installed)
        return;
    installed = YES;
    
    Method meth;

    // I believe this method is actually implemented before iOS 7, but isn't publicly exposed.
    // Just to be safe, we're going to add it if we need to.
    if (![NSArray instancesRespondToSelector:@selector(firstObject)])
    {
        meth = class_getInstanceMethod([NSArray class], @selector(firstObject));
        method_setImplementation(meth, (IMP)new__NSArray_firstObject);
    }
    
    class_addMethod([UIToolbar class], @selector(barTintColor), (IMP)new__UIToolbar_barTintColor, "@@:");
    class_addMethod([UIToolbar class], @selector(setBarTintColor:), (IMP)new__UIToolbar_setBarTintColor, "v@:@");
    
    class_addMethod([UIView class], @selector(tintColor), (IMP)new__UIView_tintColor, "@@:");
    class_addMethod([UIView class], @selector(setTintColor:), (IMP)new__UIView_setTintColor, "v@:@");
    
    class_addMethod([UITableViewCell class], @selector(separatorInset), (IMP)new__UITableViewCell_separatorInset, "{ffff}@:");
    class_addMethod([UITableViewCell class], @selector(setSeparatorInset:), (IMP)new__UITableViewCell_setSeparatorInset, "v@:{ffff}");
    
    class_addMethod([UIViewController class], @selector(setAutomaticallyAdjustsScrollViewInsets:), (IMP)new__UIViewController_setAutomaticallyAdjustsScrollViewInsets, "v@:c");
    
    class_addMethod([UINavigationBar class], @selector(barTintColor), (IMP)new__UINavigationBar_barTintColor, "@@:");
    class_addMethod([UINavigationBar class], @selector(setBarTintColor:), (IMP)new__UINavigationBar_setBarTintColor, "v@:@");
    
    class_replaceMethod([UILabel class], @selector(highlightedTextColor), (IMP)new__UILabel_highlightedTextColor, "@@:");
}

@end

#pragma mark - Hook Implementations

id new__NSArray_firstObject(NSArray *self, SEL cmd)
{
    if (![self count])
        return nil;
    return self[0];
}

id new__UIView_tintColor(UIView *self, SEL cmd)
{
    return [UIColor blueColor];
}
void new__UIView_setTintColor(UIView *self, SEL cmd, UIColor *color)
{
    
}

id new__UIToolbar_barTintColor(UIToolbar *self, SEL cmd)
{
    return self.tintColor;
}

void new__UIToolbar_setBarTintColor(UIToolbar *self, SEL cmd, UIColor *color)
{
    self.tintColor = color;
}

UIEdgeInsets new__UITableViewCell_separatorInset(id self, SEL cmd)
{
    return (UIEdgeInsets){ 0, 0, 0, 0 };
}
void new__UITableViewCell_setSeparatorInset(id self, SEL cmd, UIEdgeInsets insets)
{
    
}

void new__UIViewController_setAutomaticallyAdjustsScrollViewInsets(id self, SEL cmd, BOOL woo)
{
    
}

UIColor *new__UINavigationBar_barTintColor(UINavigationBar *self, SEL cmd)
{
    return self.tintColor;
}
void new__UINavigationBar_setBarTintColor(UINavigationBar *self, SEL cmd, UIColor *color)
{
    self.tintColor = color;
}

UIColor *new__UILabel_highlightedTextColor(id self, SEL cmd)
{
    return [UIColor whiteColor];
}


