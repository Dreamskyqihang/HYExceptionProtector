//
//  NSString+ExcepitionProtector.m
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/12/26.
//  Copyright © 2018 张鸿运. All rights reserved.
//

#import "NSString+ExcepitionProtector.h"
#import "NSObject+HYHook.h"
#import <objc/runtime.h>
#import "HYExcepitionCollector.h"

@implementation NSString (ExcepitionProtector)

+ (void)hy_swizzleMethod
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class cls = objc_getClass("NSString");
        hy_swizzleClassMethodImplementation(cls, @selector(stringWithUTF8String:), @selector(safeStringWithUTF8String:));
        hy_swizzleClassMethodImplementation(cls, @selector(stringWithCString:encoding:), @selector(safeStringWithCString:encoding:));
        
        Class clsPlaceholderString = objc_getClass("NSPlaceholderString");
        hy_swizzleInstanceMethodImplementation(clsPlaceholderString, @selector(initWithCString:encoding:), @selector(safeInitWithCString:encoding:));
        hy_swizzleInstanceMethodImplementation(clsPlaceholderString, @selector(initWithString:), @selector(safeInitWithString:));
        
        
        Class clsNSCFConstantString = objc_getClass("__NSCFConstantString");
        hy_swizzleInstanceMethodImplementation(clsNSCFConstantString, @selector(substringFromIndex:), @selector(safeSubstringFromIndex:));
        hy_swizzleInstanceMethodImplementation(clsNSCFConstantString, @selector(substringToIndex:), @selector(safeSubstringToIndex:));
        hy_swizzleInstanceMethodImplementation(clsNSCFConstantString, @selector(substringWithRange:), @selector(safeSubstringWithRange:));
        hy_swizzleInstanceMethodImplementation(clsNSCFConstantString, @selector(rangeOfString:options:range:locale:), @selector(safeRangeOfString:options:range:locale:));
        

        Class clsTaggedPointerString = objc_getClass("NSTaggedPointerString");
        hy_swizzleInstanceMethodImplementation(clsTaggedPointerString, @selector(substringFromIndex:), @selector(safeSubstringFromIndex:));
        hy_swizzleInstanceMethodImplementation(clsTaggedPointerString, @selector(substringToIndex:), @selector(safeSubstringToIndex:));
        hy_swizzleInstanceMethodImplementation(clsTaggedPointerString, @selector(substringWithRange:), @selector(safeSubstringWithRange:));
        hy_swizzleInstanceMethodImplementation(clsTaggedPointerString, @selector(rangeOfString:options:range:locale:), @selector(safeRangeOfString:options:range:locale:));
        
    });
}



+ (NSString *)safeStringWithUTF8String:(const char *)nullTerminatedCString
{
    NSString *string = nil;
    
    @try {
        
        string = [self safeStringWithUTF8String:nullTerminatedCString];
        
    } @catch (NSException *exception) {
        
        hy_handleErrorWithException(exception);
        
    } @finally {
        
        return string;
        
    }
    
}

+ (nullable instancetype)safeStringWithCString:(const char *)cString encoding:(NSStringEncoding)enc
{
    NSString *string = nil;
    
    @try {
        
        string = [self safeStringWithCString:cString encoding:enc];
        
    } @catch (NSException *exception) {
        
        hy_handleErrorWithException(exception);
        
    } @finally {
        
        return string;
        
    }
    
}

- (nullable instancetype)safeInitWithString:(id)cString
{
    NSString *string = nil;
    
    @try {
        
        string = [self safeInitWithString:cString];
        
    } @catch (NSException *exception) {
        
        hy_handleErrorWithException(exception);
        
    } @finally {
        
        return string;
        
    }
    
}

- (nullable instancetype)safeInitWithCString:(const char *)nullTerminatedCString encoding:(NSStringEncoding)encoding
{
    NSString *string = nil;
    
    @try {
        
        string = [self safeInitWithCString:nullTerminatedCString encoding:encoding];
        
    } @catch (NSException *exception) {
        
        hy_handleErrorWithException(exception);
        
    } @finally {
        
        return string;
        
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
- (NSRange)safeRangeOfString:(NSString *)searchString
                     options:(NSStringCompareOptions)mask
                       range:(NSRange)range
                      locale:(nullable NSLocale *)locale
{
    
    NSRange returnRange;
    
    @try {
        
        returnRange = [self safeRangeOfString:searchString options:mask range:range locale:locale];
        
    } @catch (NSException *exception) {
        
        if (searchString && range.location < self.length) {
            
            NSRange safeRange = NSMakeRange(range.location, self.length - 1 - range.location);
            returnRange       =  [self safeRangeOfString:searchString
                                                 options:mask
                                                   range:safeRange
                                                  locale:locale];
            
        }
        
        hy_handleErrorWithException(exception);
        
    } @finally {
        
        return returnRange;
        
    }
    
}

@end
