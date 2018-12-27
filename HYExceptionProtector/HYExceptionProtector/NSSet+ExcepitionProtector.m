//
//  NSSet+ExcepitionProtector.m
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/12/26.
//  Copyright © 2018 张鸿运. All rights reserved.
//

#import "NSSet+ExcepitionProtector.h"
#import "NSObject+HYHook.h"
#import <objc/runtime.h>
#import "HYExcepitionCollector.h"

@implementation NSSet (ExcepitionProtector)

+ (void)hy_swizzleMethod
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class cls = objc_getClass("NSSet");
        hy_swizzleClassMethodImplementation(cls, @selector(setWithObject:), @selector(safeSetWithObject:));
        
    });
}

+ (instancetype)safeSetWithObject:(id)object
{
    
    id instance = nil;
    
    @try {
        
        instance = [self safeSetWithObject:object];
        
    } @catch (NSException *exception) {
        
        hy_handleErrorWithException(exception);
        
    } @finally {
        
        return instance;
        
    }
    
}


@end
