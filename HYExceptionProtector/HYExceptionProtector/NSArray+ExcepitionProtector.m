//
//  NSArray+ExcepitionProtector.m
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/12/20.
//  Copyright © 2018 张鸿运. All rights reserved.
//

#import "NSArray+ExcepitionProtector.h"
#import "HYExcepitionCollector.h"
#import <objc/runtime.h>
#import "NSObject+HYHook.h"

@implementation NSArray (ExcepitionProtector)

+ (void)hy_swizzleMethod
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //=================
        //     类方法交换
        //=================
        [NSArray hy_swizzleClassMethodImplementation:@selector(arrayWithObject:)        withSEL:@selector(safeArrayWithObject:)];
        [NSArray hy_swizzleClassMethodImplementation:@selector(arrayWithObjects:count:) withSEL:@selector(safeArrayWithObjects:count:)];
        
        //===================
        //     实例方法交换
        //===================
        // __NSArray0
        Class clsArray0 = objc_getClass("__NSArray0");
        hy_swizzleInstanceMethodImplementation(clsArray0, @selector(objectAtIndex:),            @selector(safeObjectAtIndex:));
        hy_swizzleInstanceMethodImplementation(clsArray0, @selector(subarrayWithRange:),        @selector(safeSubarrayWithRange:));
        hy_swizzleInstanceMethodImplementation(clsArray0, @selector(objectAtIndexedSubscript:), @selector(safeObjectAtIndexedSubscript:));
        
        // __NSArrayI
        Class clsArray1 = objc_getClass("__NSArrayI");
        hy_swizzleInstanceMethodImplementation(clsArray1, @selector(objectAtIndex:),            @selector(safeObjectAtIndex:));
        hy_swizzleInstanceMethodImplementation(clsArray1, @selector(subarrayWithRange:),        @selector(safeSubarrayWithRange:));
        hy_swizzleInstanceMethodImplementation(clsArray1, @selector(objectAtIndexedSubscript:), @selector(safeObjectAtIndexedSubscript:));
        
        // __NSArrayI_Transfer
        Class clsArrayIT = objc_getClass("__NSArrayI_Transfer");
        hy_swizzleInstanceMethodImplementation(clsArrayIT, @selector(objectAtIndex:),            @selector(safeObjectAtIndex:));
        hy_swizzleInstanceMethodImplementation(clsArrayIT, @selector(subarrayWithRange:),        @selector(safeSubarrayWithRange:));
        hy_swizzleInstanceMethodImplementation(clsArrayIT, @selector(objectAtIndexedSubscript:), @selector(safeObjectAtIndexedSubscript:));
        
        
        // above iOS10  __NSSingleObjectArrayI
        Class clsArraySI = objc_getClass("__NSSingleObjectArrayI");
        hy_swizzleInstanceMethodImplementation(clsArraySI, @selector(objectAtIndex:),            @selector(safeObjectAtIndex:));
        hy_swizzleInstanceMethodImplementation(clsArraySI, @selector(subarrayWithRange:),        @selector(safeSubarrayWithRange:));
        hy_swizzleInstanceMethodImplementation(clsArraySI, @selector(objectAtIndexedSubscript:), @selector(safeObjectAtIndexedSubscript:));
        
        // __NSFrozenArrayM
        Class clsArrayM = objc_getClass("__NSFrozenArrayM");
        hy_swizzleInstanceMethodImplementation(clsArrayM, @selector(objectAtIndex:),            @selector(safeObjectAtIndex:));
        hy_swizzleInstanceMethodImplementation(clsArrayM, @selector(subarrayWithRange:),        @selector(safeSubarrayWithRange:));
        hy_swizzleInstanceMethodImplementation(clsArrayM, @selector(objectAtIndexedSubscript:), @selector(safeObjectAtIndexedSubscript:));
        
        // __NSArrayReversed
        Class clsArrayR = objc_getClass("__NSArrayReversed");
        hy_swizzleInstanceMethodImplementation(clsArrayR, @selector(objectAtIndex:),            @selector(safeObjectAtIndex:));
        hy_swizzleInstanceMethodImplementation(clsArrayR, @selector(subarrayWithRange:),        @selector(safeSubarrayWithRange:));
        hy_swizzleInstanceMethodImplementation(clsArrayR, @selector(objectAtIndexedSubscript:), @selector(safeObjectAtIndexedSubscript:));
        
    });
    
}

+ (instancetype)safeArrayWithObject:(id)anObject
{
    id array = nil;
    
    @try {
        
        array = [self safeArrayWithObject:anObject];
        
    }
    @catch (NSException *exception) {
        
        hy_handleErrorWithException(exception);
        
    }
    @finally {
        
        return array;
    }
}

- (id)safeObjectAtIndex:(NSUInteger)index
{
    id object = nil;
    
    @try {
        
        object = [self safeObjectAtIndex:index];
        
    }
    @catch (NSException *exception) {
        
        hy_handleErrorWithException(exception);
        
    }
    @finally {
        
        return object;
    }
}

- (id)safeObjectAtIndexedSubscript:(NSInteger)index
{
    id object = nil;
    
    @try {
        
        object = [self safeObjectAtIndexedSubscript:index];
        
    }
    @catch (NSException *exception) {
        
        hy_handleErrorWithException(exception);
        
    }
    @finally {
        
        return object;
    }
}

- (NSArray *)safeSubarrayWithRange:(NSRange)range
{
    NSArray *array = nil;
    
    @try {
        
        array = [self safeSubarrayWithRange:range];
        
    } @catch (NSException *exception) {
        
        array = [self safeSubarrayWithRange:NSMakeRange(range.location, self.count - range.location)];
        
        // 收集错误信息
        hy_handleErrorWithException(exception);
        
    } @finally {
        
        return array;
    }
}

+ (instancetype)safeArrayWithObjects:(const id [])objects count:(NSUInteger)cnt
{
    id array = nil;
    
    @try {
        
        array = [self safeArrayWithObjects:objects count:cnt];
        
    }
    @catch (NSException *exception) {
        
        // 把为nil的数据去掉,然后初始化数组
        NSInteger newObjsIndex = 0;
        id  _Nonnull __unsafe_unretained newObjects[cnt];
        
        for (int i = 0; i < cnt; i++) {
            
            if (objects[i] != nil) {
                
                newObjects[newObjsIndex] = objects[i];
                newObjsIndex++;
            }
        }
        
        array = [self safeArrayWithObjects:newObjects count:newObjsIndex];
        
        // 收集错误信息
        hy_handleErrorWithException(exception);
        
    }
    @finally {
        
        return array;
    }
}

@end
