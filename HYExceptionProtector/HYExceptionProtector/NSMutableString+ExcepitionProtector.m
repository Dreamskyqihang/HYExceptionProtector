//
//  NSMutableString+ExcepitionProtector.m
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/12/26.
//  Copyright © 2018 张鸿运. All rights reserved.
//

#import "NSMutableString+ExcepitionProtector.h"
#import "NSObject+HYHook.h"
#import <objc/runtime.h>
#import "HYExcepitionCollector.h"


@implementation NSMutableString (ExcepitionProtector)

+ (void)hy_swizzleMethod
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class cls = objc_getClass("__NSCFString");
        hy_swizzleInstanceMethodImplementation(cls, @selector(appendString:), @selector(safeAppendString:));
        hy_swizzleInstanceMethodImplementation(cls, @selector(insertString:atIndex:), @selector(safeInsertString:atIndex:));
        hy_swizzleInstanceMethodImplementation(cls, @selector(deleteCharactersInRange:), @selector(safeDeleteCharactersInRange:));
        hy_swizzleInstanceMethodImplementation(cls, @selector(substringFromIndex:), @selector(safeSubstringFromIndex:));
        hy_swizzleInstanceMethodImplementation(cls, @selector(substringToIndex:), @selector(safeSubstringToIndex:));
        hy_swizzleInstanceMethodImplementation(cls, @selector(substringWithRange:), @selector(safeSubstringWithRange:));
        
    });
}


- (void)safeAppendString:(NSString *)aString
{
    @try {
        
        [self safeAppendString:aString];
        
    } @catch (NSException *exception) {
        
        hy_handleErrorWithException(exception);
        
    } @finally {
        
    }
    
}

- (void)safeInsertString:(NSString *)aString atIndex:(NSUInteger)loc
{
    @try {
        
        [self safeInsertString:aString atIndex:loc];
        
    } @catch (NSException *exception) {
        
        hy_handleErrorWithException(exception);
        
    } @finally {
        
    }
    
}

- (void)safeDeleteCharactersInRange:(NSRange)range
{
    @try {
        
        [self safeDeleteCharactersInRange:range];
        
    } @catch (NSException *exception) {
        
        // 如果是起点在字符串内，但是长度超过字符串，就删除掉起点之后的字符
        if (range.location < self.length) {
            
            [self safeDeleteCharactersInRange:NSMakeRange(range.location, self.length - 1 - range.location)];
            
        }
        
        hy_handleErrorWithException(exception);
        
    } @finally {
        
    }
    
}

- (NSString *)safeSubstringFromIndex:(NSUInteger)from
{
    NSString *string = self;
    
    @try {
        
        string = [self safeSubstringFromIndex:from];
        
    } @catch (NSException *exception) {
        
        hy_handleErrorWithException(exception);
        
    } @finally {
        
        return string;
    }
    
}

- (NSString *)safeSubstringToIndex:(NSUInteger)to
{
    NSString *string = self;
    
    @try {
        
        string = [self safeSubstringToIndex:to];
        
    } @catch (NSException *exception) {
        
        hy_handleErrorWithException(exception);
        
    } @finally {
        
        return string;
    }
    
}

- (NSString *)safeSubstringWithRange:(NSRange)range
{
    NSString *string = self;
    
    @try {
        
        string = [self safeSubstringWithRange:range];
        
    } @catch (NSException *exception) {
        
        // 如果是起点在字符串内，但是长度超过字符串，就返回起点之后的字符
        if (range.location < self.length) {
            
            string = [self safeSubstringWithRange:NSMakeRange(range.location, self.length - 1 - range.location)];
            
        }
        
        hy_handleErrorWithException(exception);
        
    } @finally {
        
        return string;
    }
    
}

@end
