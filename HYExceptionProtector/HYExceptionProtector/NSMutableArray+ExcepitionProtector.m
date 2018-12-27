//
//  NSMutableArray+ExcepitionProtector.m
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/12/20.
//  Copyright © 2018 张鸿运. All rights reserved.
//

#import "NSMutableArray+ExcepitionProtector.h"
#import "HYExcepitionCollector.h"
#import <objc/runtime.h>
#import "NSObject+HYHook.h"

@implementation NSMutableArray (ExcepitionProtector)

+ (void)hy_swizzleMethod
{
    Class clsArrayM = objc_getClass("__NSArrayM");
    hy_swizzleInstanceMethodImplementation(clsArrayM, @selector(addObject:),@selector(safeAddObject:));
    hy_swizzleInstanceMethodImplementation(clsArrayM, @selector(objectAtIndex:),        @selector(safeObjectAtIndex:));
    hy_swizzleInstanceMethodImplementation(clsArrayM, @selector(objectAtIndexedSubscript:), @selector(safeObjectAtIndexedSubscript:));
    hy_swizzleInstanceMethodImplementation(clsArrayM, @selector(insertObject:atIndex:), @selector(safeInsertObject:atIndex:));
    hy_swizzleInstanceMethodImplementation(clsArrayM, @selector(removeObjectAtIndex:), @selector(safeRemoveObjectAtIndex:));
    hy_swizzleInstanceMethodImplementation(clsArrayM, @selector(replaceObjectAtIndex:withObject:), @selector(safeReplaceObjectAtIndex:withObject:));
    hy_swizzleInstanceMethodImplementation(clsArrayM, @selector(removeObjectsInRange:), @selector(safeRemoveObjectsInRange:));
    hy_swizzleInstanceMethodImplementation(clsArrayM, @selector(subarrayWithRange:), @selector(safeSubarrayWithRange:));

}

- (void)safeAddObject:(id)anObject
{
    @try {
        
        [self safeAddObject:anObject];
        
    } @catch (NSException *exception) {
        
        hy_handleErrorWithException(exception);
        
    } @finally {
        
    }

}

- (id)safeObjectAtIndex:(NSUInteger)index
{
    id object = nil;
    
    @try {
        
        object = [self safeObjectAtIndex:index];
        
    } @catch (NSException *exception) {
        
        object = [self lastObject];
        
        hy_handleErrorWithException(exception);

    } @finally {
        
        return  object;
    }

}

- (id)safeObjectAtIndexedSubscript:(NSInteger)index
{
    id object = nil;
    
    @try {
        
        object = [self safeObjectAtIndexedSubscript:index];
        
    } @catch (NSException *exception) {
        
        object = [self lastObject];
        
        hy_handleErrorWithException(exception);
        
    } @finally {
        
        return  object;
        
    }
    
}

- (void)safeInsertObject:(id)anObject atIndex:(NSUInteger)index
{
    @try {
        
        [self safeInsertObject:anObject atIndex:index];
        
    } @catch (NSException *exception) {
        
        hy_handleErrorWithException(exception);

    } @finally {
        
    }

}

- (void)safeRemoveObjectAtIndex:(NSUInteger)index
{
    @try {
        
        [self safeRemoveObjectAtIndex:index];
        
    } @catch (NSException *exception) {
        
        hy_handleErrorWithException(exception);
        
    } @finally {
        
    }

}


- (void)safeReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    @try {
        
        [self safeReplaceObjectAtIndex:index withObject:anObject];

    } @catch (NSException *exception) {
        
        hy_handleErrorWithException(exception);
        
    } @finally {
        
    }

}

- (void)safeRemoveObjectsInRange:(NSRange)range
{
    @try {
        
        [self safeRemoveObjectsInRange:range];

    } @catch (NSException *exception) {
        
        hy_handleErrorWithException(exception);
        
    } @finally {
        
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

@end
