//
//  NSDictionary+ExcepitionProtector.m
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/12/20.
//  Copyright © 2018 张鸿运. All rights reserved.
//

#import "NSDictionary+ExcepitionProtector.h"
#import "HYExcepitionCollector.h"
#import <objc/runtime.h>
#import "NSObject+HYHook.h"

@implementation NSDictionary (ExcepitionProtector)

+ (void)hy_swizzleMethod
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        hy_swizzleClassMethodImplementation([self class], @selector(dictionaryWithObject:forKey:), @selector(safeDictionaryWithObject:forKey:));
        hy_swizzleClassMethodImplementation([self class], @selector(dictionaryWithObjects:forKeys:count:), @selector(safeDictionaryWithObjects:forKeys:count:));
        
        
        Class clsSingleEntryDictionaryI = objc_getClass("__NSSingleEntryDictionaryI");
        hy_swizzleInstanceMethodImplementation(clsSingleEntryDictionaryI, @selector(initWithObjectsAndKeys:), @selector(safeInitWithObjectsAndKeys:));
        hy_swizzleInstanceMethodImplementation(clsSingleEntryDictionaryI, @selector(initWithObjects:forKeys:), @selector(safeInitWithObjects:forKeys:));
        
    });
    
}

- (instancetype)safeInitWithObjects:(NSArray *)objects forKeys:(NSArray<id<NSCopying>> *)keys
{
    id dictionary = nil;
    
    @try {
        
        dictionary = [self safeInitWithObjects:objects forKeys:keys];
        
    } @catch (NSException *exception) {
        
        if (objects && keys) {
            
            NSInteger count            = objects.count > keys.count ? keys.count : objects.count;
           
            NSMutableArray *newObjects = [NSMutableArray arrayWithCapacity:count];
            NSMutableArray *newkeys    = [NSMutableArray arrayWithCapacity:count];
            
            for (NSInteger i = 0; i < count; i++) {
                
                if (objects[i] && keys[i]) {
                    
                    newObjects[i] = objects[i];
                    newkeys[i]    = keys[i];
                    
                }
            }
            
            dictionary = [self safeInitWithObjects:newObjects forKeys:newkeys];
            
        }
        // 收集错误信息
        hy_handleErrorWithException(exception);
        
    } @finally {
        
        return dictionary;
        
    }
}

- (instancetype)safeInitWithObjectsAndKeys:(id)firstObject, ...
{
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    va_list list;
    va_start(list, firstObject);
    [objects addObject:firstObject];
    id arg = nil;
    while ((arg = va_arg(list, id))) {
        
        [objects addObject:arg];
    }
    va_end(list);
    
    if (objects.count % 2 != 0) {
        NSException *exception = [[NSException alloc] initWithName:NSInvalidArgumentException
                                                            reason:@"-[__NSPlaceholderDictionary initWithObjectsAndKeys:]: second object of each pair must be non-nil"
                                                          userInfo:nil];
        // 收集错误信息
        hy_handleErrorWithException(exception);

    }
    
    // 对参数处理，丢弃最后一个参数，然后组成一个字典
    NSInteger index        = objects.count % 2 == 0 ? objects.count : objects.count - 1;
    NSMutableArray *keys   = [NSMutableArray arrayWithCapacity:objects.count / 2];
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:objects.count / 2];
    for (NSInteger i = 0; i < index; i++) {
        
        if (i % 2 == 0) {
            
            [values addObject:objects[i]];
            
        } else {
            
            [keys addObject:objects[i]];
            
        }
    }
    
    return [[NSDictionary alloc] initWithObjects:[values copy] forKeys:[keys copy]];
    
}

+ (instancetype)safeDictionaryWithObject:(id)object forKey:(id)key
{
    id dictionary = nil;

    @try {
        
        dictionary = [self safeDictionaryWithObject:object forKey:key];
        
    } @catch (NSException *exception) {
                
        // 收集错误信息
        hy_handleErrorWithException(exception);
        
    } @finally {
        
        return dictionary;
    }

}

+ (instancetype)safeDictionaryWithObjects:(const id [])objects forKeys:(const id [])keys count:(NSUInteger)cnt
{
    id dictionary = nil;
    
    @try {
        
        dictionary = [self safeDictionaryWithObjects:objects forKeys:keys count:cnt];
        
    }
    @catch (NSException *exception) {
        
        // 处理错误的数据，然后重新初始化一个字典
        NSUInteger index = 0;
        id  _Nonnull __unsafe_unretained newObjects[cnt];
        id  _Nonnull __unsafe_unretained newkeys[cnt];
        
        for (int i = 0; i < cnt; i++) {
            
            if (objects[i] && keys[i]) {
                
                newObjects[index] = objects[i];
                newkeys[index]    = keys[i];
                index++;
                
            }
            
        }
        dictionary = [self safeDictionaryWithObjects:newObjects forKeys:newkeys count:index];
        
        // 收集错误信息
        hy_handleErrorWithException(exception);
        
    }
    @finally {
        
        return dictionary;
        
    }
}


@end
