//
//  NSMutableSet+ExcepitionProtector.m
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/12/26.
//  Copyright © 2018 张鸿运. All rights reserved.
//

#import "NSMutableSet+ExcepitionProtector.h"
#import "NSObject+HYHook.h"
#import <objc/runtime.h>
#import "HYExcepitionCollector.h"


@implementation NSMutableSet (ExcepitionProtector)


+ (void)hy_swizzleMethod
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class cls = objc_getClass("NSMutableSet");
        hy_swizzleInstanceMethodImplementation(cls, @selector(addObject:), @selector(safeddObject:));
        hy_swizzleInstanceMethodImplementation(cls, @selector(removeObject:), @selector(safeRemoveObject:));
        
    });
}


- (void)safeddObject:(id)object
{
    @try {
        
        [self safeddObject:object];
        
    } @catch (NSException *exception) {
        
        hy_handleErrorWithException(exception);
        
    } @finally {
        
    }
}

- (void)safeRemoveObject:(id)object
{
    @try {
        
        [self safeRemoveObject:object];
        
    } @catch (NSException *exception) {
        
        hy_handleErrorWithException(exception);
        
    } @finally {
        
    }
}

@end
