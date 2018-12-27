//
//  NSMutableDictionary+ExcepitionProtector.m
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/12/25.
//  Copyright © 2018 张鸿运. All rights reserved.
//

#import "NSMutableDictionary+ExcepitionProtector.h"
#import "HYExcepitionCollector.h"
#import <objc/runtime.h>
#import "NSObject+HYHook.h"

@implementation NSMutableDictionary (ExcepitionProtector)

+ (void)hy_swizzleMethod
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class clsDictinaryM = objc_getClass("__NSDictionaryM");
        hy_swizzleInstanceMethodImplementation(clsDictinaryM, @selector(setObject:forKey:), @selector(safeSetObject:forKey:));
        hy_swizzleInstanceMethodImplementation(clsDictinaryM, @selector(setObject:forKeyedSubscript:), @selector(safeSetObject:forKeyedSubscript:));
        hy_swizzleInstanceMethodImplementation(clsDictinaryM, @selector(removeObjectForKey:), @selector(safeRemoveObjectForKey:));

    });
}


- (void)safeSetObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    
    @try {
        
        [self safeSetObject:anObject forKey:aKey];
        
    }
    @catch (NSException *exception) {

        // 收集错误信息
        hy_handleErrorWithException(exception);
        
    }
    @finally {
        
    }
}


- (void)safeSetObject:(id)obj forKeyedSubscript:(id<NSCopying>)key
{
    @try {
        
        [self safeSetObject:obj forKeyedSubscript:key];
        
    }
    @catch (NSException *exception) {
        
        // 收集错误信息
        hy_handleErrorWithException(exception);

    }
    @finally {
        
    }
}


- (void)safeRemoveObjectForKey:(id)aKey
{
    
    @try {
        
        [self safeRemoveObjectForKey:aKey];
        
    }
    @catch (NSException *exception) {
        
        // 收集错误信息
        hy_handleErrorWithException(exception);
        
    }
    @finally {
        
    }
}


@end
