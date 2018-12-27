//
//  NSObject+KVOCrashProtector.m
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/12/25.
//  Copyright © 2018 张鸿运. All rights reserved.
//

#import "NSObject+KVOCrashProtector.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSObject+HYHook.h"
#import "HYExcepitionCollector.h"

static const char DeallocKVOKey;
static const char ObserverDeallocKVOKey;


@interface KVOObjectItem : NSObject

@property (nonatomic, strong) NSObject                   *observer;
@property (nonatomic, copy)   NSString                   *keyPath;
@property (nonatomic, assign) NSKeyValueObservingOptions options;
@property (nonatomic, assign) void                       *context;

@end

@implementation KVOObjectItem

- (BOOL)isEqual:(KVOObjectItem *)object
{
    if ([self.observer isEqual:object.observer]
        && [self.keyPath isEqualToString:object.keyPath]) return YES;
    
    return NO;
}

- (NSUInteger)hash
{
    return [self.observer hash] ^ [self.keyPath hash];
}

@end


@interface KVOObjectContainer : NSObject

@property (nonatomic, retain)            NSMutableSet         *kvoObjectSet;

@property (nonatomic, unsafe_unretained) NSObject             *whichObject;

#if OS_OBJECT_HAVE_OBJC_SUPPORT
@property (nonatomic, retain)            dispatch_semaphore_t kvoLock;
#else
@property (nonatomic, assign)            dispatch_semaphore_t kvoLock;
#endif

- (void)addKVOObjectItem:(KVOObjectItem *)item;

- (void)removeKVOObjectItem:(KVOObjectItem *)item;

- (BOOL)checkKVOItemExist:(KVOObjectItem *)item;

@end

@implementation KVOObjectContainer

- (void)addKVOObjectItem:(KVOObjectItem *)item
{
    if (item) {
        
        dispatch_semaphore_wait(self.kvoLock, DISPATCH_TIME_FOREVER);
        [self.kvoObjectSet addObject:item];
        dispatch_semaphore_signal(self.kvoLock);
    }
}

- (void)removeKVOObjectItem:(KVOObjectItem *)item
{
    if (item) {
        
        dispatch_semaphore_wait(self.kvoLock, DISPATCH_TIME_FOREVER);
        [self.kvoObjectSet removeObject:item];
        dispatch_semaphore_signal(self.kvoLock);
    }
}

- (BOOL)checkKVOItemExist:(KVOObjectItem *)item
{
    dispatch_semaphore_wait(self.kvoLock, DISPATCH_TIME_FOREVER);
    BOOL exist = NO;
    if (!item) {
        
        dispatch_semaphore_signal(self.kvoLock);
        return exist;
        
    }
    exist = [self.kvoObjectSet containsObject:item];
    dispatch_semaphore_signal(self.kvoLock);
   
    return exist;
}

- (dispatch_semaphore_t)kvoLock
{
    if (!_kvoLock) {
        
        _kvoLock = dispatch_semaphore_create(1);
        return _kvoLock;
        
    }
   
    return _kvoLock;
}


- (void)cleanKVOData
{
    for (KVOObjectItem *item in self.kvoObjectSet) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        @try {
            
            ((void(*)(id, SEL, id, NSString *))objc_msgSend)(self.whichObject, @selector(hookRemoveObserver:forKeyPath:), item.observer, item.keyPath);
            
        }
        @catch (NSException *exception) {
            
        }
#pragma clang diagnostic pop
    }
}

- (NSMutableSet *)kvoObjectSet
{
    if (!_kvoObjectSet) {
        
        _kvoObjectSet = [[NSMutableSet alloc] init];
    }
    
    return _kvoObjectSet;
}

@end

@interface HYObserverContainer : NSObject

@property (nonatomic, retain) NSHashTable *observers;

@property (nonatomic, assign) NSObject *whichObject;

- (void)addObserver:(KVOObjectItem *)observer;

- (void)removeObserver:(KVOObjectItem *)observer;

@end

@implementation HYObserverContainer

- (instancetype)init
{
    if (self = [super init]) {
        
        self.observers = [NSHashTable hashTableWithOptions:NSMapTableWeakMemory];
    }
    
    return self;
}

- (void)addObserver:(KVOObjectItem *)observer
{
    @synchronized (self) {
        
        [self.observers addObject:observer];
        
    }
}

- (void)removeObserver:(KVOObjectItem *)observer
{
    @synchronized (self) {
        
        [self.observers removeObject:observer];
        
    }
}

- (void)cleanObservers
{
    for (KVOObjectItem *item in self.observers) {
        
        [self.whichObject removeObserver:item.observer forKeyPath:item.keyPath];
        
    }
    
    @synchronized (self) {
        
        [self.observers removeAllObjects];
    }
}

@end

@implementation NSObject (KVOCrashProtector)

+ (void)hy_KVOCrashProtectorSwizzleMethod
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        hy_swizzleInstanceMethodImplementation([self class], @selector(addObserver:forKeyPath:options:context:), @selector(safeAddObserver:forKeyPath:options:context:));
        hy_swizzleInstanceMethodImplementation([self class], @selector(removeObserver:forKeyPath:), @selector(safeRemoveObserver:forKeyPath:));
        hy_swizzleInstanceMethodImplementation([self class], @selector(removeObserver:forKeyPath:context:), @selector(safeRemoveObserver:forKeyPath:context:));
        
    });
    
}

- (void)safeAddObserver:(NSObject *)observer
             forKeyPath:(NSString *)keyPath
                options:(NSKeyValueObservingOptions)options
                context:(void *)context
{
    if ([self ignoreKVOInstanceClass:observer]) {
        
        [self safeAddObserver:observer
                   forKeyPath:keyPath
                      options:options
                      context:context];
        return;
    }
    
    if (!observer || keyPath.length == 0) return;
    
    KVOObjectContainer *objectContainer = objc_getAssociatedObject(self, &DeallocKVOKey);
    
    KVOObjectItem *item = [[KVOObjectItem alloc] init];
    item.observer       = observer;
    item.keyPath        = keyPath;
    item.options        = options;
    item.context        = context;
    
    if (!objectContainer) {
        
        objectContainer = [[KVOObjectContainer alloc] init];
        [objectContainer setWhichObject:self];
        objc_setAssociatedObject(self, &DeallocKVOKey, objectContainer, OBJC_ASSOCIATION_RETAIN);
    }
    
    if (![objectContainer checkKVOItemExist:item]) {
        
        [objectContainer addKVOObjectItem:item];
        [self safeAddObserver:observer
                   forKeyPath:keyPath
                      options:options
                      context:context];
    }
    
    HYObserverContainer *observerContainer = objc_getAssociatedObject(observer, &ObserverDeallocKVOKey);
    
    if (!observerContainer) {
        
        observerContainer = [[HYObserverContainer alloc] init];
        [observerContainer setWhichObject:self];
        [observerContainer addObserver:item];
        objc_setAssociatedObject(observer, &ObserverDeallocKVOKey, observerContainer, OBJC_ASSOCIATION_RETAIN);
        
    } else {
        
        [observerContainer addObserver:item];
    }
    
    
}

- (void)safeRemoveObserver:(NSObject *)observer
                forKeyPath:(NSString *)keyPath
                   context:(void *)context
{
    if ([self ignoreKVOInstanceClass:observer]) {
        
        [self safeRemoveObserver:observer
                      forKeyPath:keyPath
                         context:context];
        return;
    }
    
    [self removeObserver:observer forKeyPath:keyPath];
}

- (void)safeRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    if ([self ignoreKVOInstanceClass:observer]) {
        
        [self safeRemoveObserver:observer forKeyPath:keyPath];
        
        return;
    }
    
    KVOObjectContainer *objectContainer = objc_getAssociatedObject(self, &DeallocKVOKey);
    
    if (!observer || !objectContainer) return;
    
    KVOObjectItem *item = [[KVOObjectItem alloc] init];
    item.observer       = observer;
    item.keyPath        = keyPath;
    
    if ([objectContainer checkKVOItemExist:item]) {
        
        @try {
            
            [self safeRemoveObserver:observer forKeyPath:keyPath];
        }
        @catch (NSException *exception) {
            
            hy_handleErrorWithException(exception);
        }
        
        [objectContainer removeKVOObjectItem:item];
        
    } else {
        
        NSException *exception = [[NSException alloc] initWithName:@""
                                                            reason:@""
                                                          userInfo:nil];
        hy_handleErrorWithException(exception);
    }
    
}

- (BOOL)ignoreKVOInstanceClass:(id)object
{
    
    if (!object) return NO;
    
    // Ignore ReactiveCocoa
    if (object_getClass(object) == objc_getClass("RACKVOProxy")) return YES;
    
    // Ignore AMAP
    NSString *className = NSStringFromClass(object_getClass(object));
    if ([className hasPrefix:@"AMap"]) return YES;
    
    return NO;
}


- (void)hy_cleanKVO
{
    
    KVOObjectContainer *objectContainer    = objc_getAssociatedObject(self, &DeallocKVOKey);
    HYObserverContainer *observerContainer = objc_getAssociatedObject(self, &ObserverDeallocKVOKey);
    
    if (objectContainer) {
        
        [objectContainer cleanKVOData];
        
    } else if (observerContainer) {
        
        [observerContainer cleanObservers];
        
    }
}

@end
