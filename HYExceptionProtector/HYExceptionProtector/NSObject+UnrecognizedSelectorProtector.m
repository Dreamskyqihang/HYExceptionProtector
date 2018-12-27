//
//  NSObject+UnrecognizedSelectorProtector.m
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/12/19.
//  Copyright © 2018 张鸿运. All rights reserved.
//

#import "NSObject+UnrecognizedSelectorProtector.h"
#import "NSObject+HYHook.h"
#import <objc/runtime.h>
#import "HYExcepitionCollector.h"

@implementation NSObject (UnrecognizedSelectorProtector)

+ (void)hy_UnrecognizedSelectorProtectorSwizzleMethod
{
    hy_swizzleInstanceMethodImplementation([self class], @selector(methodSignatureForSelector:), @selector(safeMethodSignatureForSelector:));
    hy_swizzleInstanceMethodImplementation([self class], @selector(forwardInvocation:), @selector(safeForwardInvocation:));
}


- (NSMethodSignature *)safeMethodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *methodSignature = [self safeMethodSignatureForSelector:aSelector];
    if (methodSignature) return methodSignature;

    
    IMP originIMP       = class_getMethodImplementation([NSObject class], @selector(methodSignatureForSelector:));
    IMP currentClassIMP = class_getMethodImplementation([self class],     @selector(methodSignatureForSelector:));
    // 如果子类重载了该方法，则返回nil
    if (originIMP != currentClassIMP) return nil;

    
    // - (void)xxxx
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

- (void)safeForwardInvocation:(NSInvocation *)invocation
{
    NSString *reason = [NSString stringWithFormat:@"class:[%@] not found selector:(%@)",NSStringFromClass(self.class),NSStringFromSelector(invocation.selector)];

    NSException *exception = [NSException exceptionWithName:@"Unrecognized Selector"
                                                     reason:reason
                                                   userInfo:nil];
    // 收集错误信息
    hy_handleErrorWithException(exception);

}


@end
