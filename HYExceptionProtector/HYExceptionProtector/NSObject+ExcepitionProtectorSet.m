//
//  NSObject+ExcepitionProtectorSet.m
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/12/26.
//  Copyright © 2018 张鸿运. All rights reserved.
//

#import "NSObject+ExcepitionProtectorSet.h"
#import "NSObject+HYHook.h"
#import "NSObject+UnrecognizedSelectorProtector.h"
#import "NSObject+KVOCrashProtector.h"

@implementation NSObject (ExcepitionProtectorSet)

+ (void)hy_swizzleMethod
{
    // 防止KVO崩溃的处理
    [self hy_KVOCrashProtectorSwizzleMethod];
    
    // 防止未实现方法引起的崩溃
    [self hy_UnrecognizedSelectorProtectorSwizzleMethod];
    
}

@end
