//
//  UIView+ExcepitionProtector.m
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/12/25.
//  Copyright © 2018 张鸿运. All rights reserved.
//

#import "UIView+ExcepitionProtector.h"
#import "HYExcepitionCollector.h"
#import <objc/runtime.h>
#import "NSObject+HYHook.h"

@implementation UIView (ExcepitionProtector)

+ (void)hy_swizzleMethod
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class cls = objc_getClass("UIView");
        hy_swizzleInstanceMethodImplementation(cls, @selector(setNeedsLayout), @selector(safeSetNeedsLayout));
        hy_swizzleInstanceMethodImplementation(cls, @selector(setNeedsDisplay), @selector(safeSetNeedsDisplay));
        hy_swizzleInstanceMethodImplementation(cls, @selector(setNeedsDisplayInRect:), @selector(safeSetNeedsDisplayInRect:));

    });
}


- (void)safeSetNeedsLayout
{
    
    if (![NSThread isMainThread]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self safeSetNeedsLayout];
            
        });
        
#if DEBUG
        NSString *message = [NSString stringWithFormat:@"You can not display UI on a background thread,-[%@ safeSetNeedsLayout]", [self class]];
        NSAssert(false, message);
#endif
        
    }
    
    [self safeSetNeedsLayout];
    
}

- (void)safeSetNeedsDisplay
{

    if (![NSThread isMainThread]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self safeSetNeedsDisplay];
            
        });
        
#if DEBUG
        NSString *message = [NSString stringWithFormat:@"You can not display UI on a background thread,-[%@ safeSetNeedsDisplay]", [self class]];
        NSAssert(false, message);
#endif
        
    }
    
    [self safeSetNeedsDisplay];
    
}

- (void)safeSetNeedsDisplayInRect:(CGRect)rect
{
    if (![NSThread isMainThread]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self safeSetNeedsDisplayInRect:rect];
            
        });
        
#if DEBUG
        
        NSString *message = [NSString stringWithFormat:@"You can not display UI on a background thread,-[%@ safeSetNeedsDisplayInRect:]", [self class]];
        NSAssert(false, message);
#endif
        
    }
    
    [self safeSetNeedsDisplayInRect:rect];

}


@end
