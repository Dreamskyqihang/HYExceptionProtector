//
//  NSObject+HYHook.m
//  HYUsersTraceRecordDemo
//
//  Created by 张鸿运 on 2018/10/17.
//  Copyright © 2018年 张鸿运. All rights reserved.
//

#import "NSObject+HYHook.h"
#import <objc/runtime.h>

void hy_swizzleInstanceMethodImplementation(Class cls, SEL originSelector, SEL swizzledSelector)
{
    if (!cls) return;

    Method originalMethod = class_getInstanceMethod(cls, originSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);

    BOOL didAddMethod =  class_addMethod(cls,
                                         originSelector,
                                         method_getImplementation(swizzledMethod),
                                         method_getTypeEncoding(swizzledMethod));

    if (didAddMethod) {
        class_replaceMethod(cls,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        class_replaceMethod(cls,
                            swizzledSelector,
                            class_replaceMethod(cls,
                                                originSelector,
                                                method_getImplementation(swizzledMethod),
                                                method_getTypeEncoding(swizzledMethod)),
                            method_getTypeEncoding(originalMethod));
        // 用此方法引起未知崩溃，原因待查
        // method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

void hy_swizzleClassMethodImplementation(Class cls, SEL originSelector, SEL swizzledSelector)
{
    if (!cls) return;

    Class metacls = objc_getMetaClass(NSStringFromClass(cls).UTF8String);

    Method originalMethod = class_getClassMethod(cls, originSelector);
    Method swizzledMethod = class_getClassMethod(cls, swizzledSelector);

    BOOL didAddMethod = class_addMethod(metacls,
                                        originSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(metacls,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));

    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}



@implementation NSObject (HYHook)

+ (void)hy_swizzleInstanceMethodImplementation:(SEL)originSelector withSEL:(SEL)swizzledSelector
{
    Class class = [self class];
    
    hy_swizzleInstanceMethodImplementation(class, originSelector, swizzledSelector);
}

+ (void)hy_swizzleClassMethodImplementation:(SEL)originSelector withSEL:(SEL)swizzledSelector
{
    Class class = [self class];
    
    hy_swizzleClassMethodImplementation(class, originSelector, swizzledSelector);
    
}

@end

