//
//  NSTimer+ExcepitionProtector.m
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/12/26.
//  Copyright © 2018 张鸿运. All rights reserved.
//

#import "NSTimer+ExcepitionProtector.h"
#import "NSObject+HYHook.h"
#import <objc/runtime.h>
#import "HYExcepitionCollector.h"

@interface TimerTagetAgent : NSObject

@property (nonatomic, assign) NSTimeInterval ti;
@property (nonatomic, weak)   id             target;
@property (nonatomic, assign) SEL            selector;
@property (nonatomic, assign) id             userInfo;
@property (nonatomic, weak)   NSTimer        *timer;
@property (nonatomic, copy)   NSString       *targetClassName;
@property (nonatomic, copy)   NSString       *targetMethodName;

@end


@implementation TimerTagetAgent

- (void)fireTimer
{
    if (!self.target) {
        
        [self.timer invalidate];
        self.timer = nil;
        NSString *reason = [NSString stringWithFormat:@"In [%@ %@], a instance has release, but the timer has not invalidate", self.targetClassName, self.targetMethodName];
        NSException *exception = [[NSException alloc] initWithName:@"NSTimer Exception"
                                                            reason:reason
                                                          userInfo:nil];
        hy_handleErrorWithException(exception);
        return;
    }
    
    if ([self.target respondsToSelector:self.selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.selector withObject:self.timer];
#pragma clang diagnostic pop
    }
}

@end

@implementation NSTimer (ExcepitionProtector)

+ (void)hy_swizzleMethod
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        hy_swizzleClassMethodImplementation([NSTimer class], @selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:), @selector(safeScheduledTimerWithTimeInterval:target:selector:userInfo:repeats:));
        
        
    });
}

+ (NSTimer *)safeScheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                         target:(id)aTarget
                                       selector:(SEL)aSelector
                                       userInfo:(nullable id)userInfo
                                        repeats:(BOOL)yesOrNo
{
    if (!yesOrNo) {
        
        return [self safeScheduledTimerWithTimeInterval:ti
                                                 target:aTarget
                                               selector:aSelector
                                               userInfo:userInfo
                                                repeats:yesOrNo];
    }
    
    TimerTagetAgent *agent = [TimerTagetAgent new];
    agent.ti               = ti;
    agent.target           = aTarget;
    agent.selector         = aSelector;
    agent.userInfo         = userInfo;
    
    if (aTarget) {
        
        agent.targetClassName = [NSString stringWithCString:object_getClassName(aTarget)
                                                   encoding:NSASCIIStringEncoding];
    }
    agent.targetMethodName    = NSStringFromSelector(aSelector);
    
    NSTimer *timer = [NSTimer safeScheduledTimerWithTimeInterval:ti
                                                          target:agent
                                                        selector:@selector(fireTimer)
                                                        userInfo:userInfo
                                                         repeats:yesOrNo];
    agent.timer = timer;
    
    return timer;
    
}

@end
