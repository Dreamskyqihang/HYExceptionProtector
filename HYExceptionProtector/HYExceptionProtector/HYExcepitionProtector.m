//
//  HYExcepitionProtector.m
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/10/22.
//  Copyright © 2018年 张鸿运. All rights reserved.
//

#import "HYExcepitionProtector.h"
#import "HYExcepitionProtectedProtocol.h"
#import <UIKit/UIKit.h>


HYExcepitionProtectorStrategy const HYExcepitionProtectorStrategyUnrecognizedSelector = @"NSObject";
HYExcepitionProtectorStrategy const HYExcepitionProtectorStrategyArray                = @"NSArray";
HYExcepitionProtectorStrategy const HYExcepitionProtectorStrategyDictionary           = @"NSDictionary";
HYExcepitionProtectorStrategy const HYExcepitionProtectorStrategyUIView               = @"UIView";
HYExcepitionProtectorStrategy const HYExcepitionProtectorStrategyNSTimer              = @"NSTimer";
HYExcepitionProtectorStrategy const HYExcepitionProtectorStrategyString               = @"NSString";
HYExcepitionProtectorStrategy const HYExcepitionProtectorStrategyAll                  = @"All";


@interface HYExcepitionProtector ()
{
    // 保护交换方法的安全
    dispatch_semaphore_t _swizzleLock;
}
@property (nonatomic, copy)   NSArray<HYExcepitionProtectorStrategy> *protectedStrategysArray;
@property (nonatomic, strong) NSMutableArray<Class>                  *protectedClassArray;

@end

@implementation HYExcepitionProtector

- (instancetype)init
{
    if (self = [super init]) {
        
        _swizzleLock = dispatch_semaphore_create(1);
        
    }
    return self;
}

#pragma mark - Public Method

+ (instancetype)shareInstance
{
    static HYExcepitionProtector *instance;
    static dispatch_once_t       onceToken;
    
    dispatch_once(&onceToken, ^{
        
        instance = [[HYExcepitionProtector alloc] init];
        
    });
    
    return instance;
}

- (void)configProtectType:(HYExcepitionProtectorStrategy)type
{
    if ([type isEqualToString:HYExcepitionProtectorStrategyAll]) {
        
        [self configAllProtectTypes];
        return;
        
    }
    
    if ([type isEqualToString:HYExcepitionProtectorStrategyArray]) {
        
        Class cls = NSClassFromString(@"NSArray");
        [self addClassToArray:cls];

        
        Class clsM = NSClassFromString(@"NSMutableArray");
        [self addClassToArray:clsM];
        
        return;
        
    }
    
    if ([type isEqualToString:HYExcepitionProtectorStrategyDictionary]) {
        
        Class cls = NSClassFromString(@"NSDictionary");
        [self addClassToArray:cls];
        
        
        Class clsM = NSClassFromString(@"NSMutableDictionary");
        [self addClassToArray:clsM];
        
        return;
        
    }
    
    if ([type isEqualToString:HYExcepitionProtectorStrategyString]) {
        
        Class cls = NSClassFromString(@"NSString");
        [self addClassToArray:cls];
        
        
        Class clsM = NSClassFromString(@"NSMutableString");
        [self addClassToArray:clsM];
        
        return;
        
    }
    
    Class cls = NSClassFromString(type);
    [self addClassToArray:cls];
   
}


- (void)configProtectTypes:(NSArray<HYExcepitionProtectorStrategy> *)types
{
    [types enumerateObjectsUsingBlock:^(HYExcepitionProtectorStrategy  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        if ([obj isEqualToString:HYExcepitionProtectorStrategyAll]) {
           
            * stop = YES;
            [self configAllProtectTypes];
            
        }
        
        [self configProtectType:obj];
        
    }];
}

- (void)configAllProtectTypes
{
    __weak typeof(self) weakSelf = self;
    [self.protectedStrategysArray enumerateObjectsUsingBlock:^(HYExcepitionProtectorStrategy _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        [weakSelf configProtectType:obj];
        
    }];
}

- (void)startProtection
{
    dispatch_semaphore_wait(_swizzleLock, DISPATCH_TIME_FOREVER);
    
    [self.protectedClassArray enumerateObjectsUsingBlock:^(Class  _Nonnull cls, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [cls performSelector:@selector(hy_swizzleMethod)];

    }];
    
    dispatch_semaphore_signal(_swizzleLock);

}

#pragma mark - Private Method

- (void)addClassToArray:(Class)cls
{
    if ([cls conformsToProtocol:@protocol(HYExcepitionProtectedProtocol)]) {
        
        [self.protectedClassArray addObject:cls];
        
    };
}


#pragma mark - getter / setter

- (NSArray *)protectedStrategysArray
{
    if (!_protectedStrategysArray) {
        
        _protectedStrategysArray = @[HYExcepitionProtectorStrategyArray,
                                     HYExcepitionProtectorStrategyDictionary,
                                     HYExcepitionProtectorStrategyUnrecognizedSelector,
                                     HYExcepitionProtectorStrategyUIView,
                                     HYExcepitionProtectorStrategyNSTimer,
                                     HYExcepitionProtectorStrategyString];
    }
    
    return _protectedStrategysArray;
}

- (NSMutableArray *)protectedClassArray
{
    if (!_protectedClassArray) {
       
        _protectedClassArray = [[NSMutableArray alloc] init];
    }
    
    return _protectedClassArray;
}
@end

