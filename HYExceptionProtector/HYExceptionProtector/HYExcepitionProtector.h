//
//  HYExcepitionProtector.h
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/10/22.
//  Copyright © 2018年 张鸿运. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
#define HY_EXTERN        extern "C" __attribute__((visibility ("default")))
#else
#define HY_EXTERN        extern __attribute__((visibility ("default")))
#endif


typedef NSString * HYExcepitionProtectorStrategy;
/** 保护未实现方法的崩溃 */
HY_EXTERN HYExcepitionProtectorStrategy const HYExcepitionProtectorStrategyUnrecognizedSelector;
/** 保护数组崩溃 */
HY_EXTERN HYExcepitionProtectorStrategy const HYExcepitionProtectorStrategyArray;
/** 保护字典崩溃 */
HY_EXTERN HYExcepitionProtectorStrategy const HYExcepitionProtectorStrategyDictionary;
/** 保护NSTimer崩溃 */
HY_EXTERN HYExcepitionProtectorStrategy const HYExcepitionProtectorStrategyNSTimer;
/** 保护字符串崩溃 */
HY_EXTERN HYExcepitionProtectorStrategy const HYExcepitionProtectorStrategyString;
/** 保护所有类型崩溃 */
HY_EXTERN HYExcepitionProtectorStrategy const HYExcepitionProtectorStrategyAll;
/** 开发过程中，使在子线程中刷新UI的操作崩溃，线上保护崩溃 */
HY_EXTERN HYExcepitionProtectorStrategy const HYExcepitionProtectorStrategyUIView;


@interface HYExcepitionProtector : NSObject

/** 当有崩溃操作时，是否显示警告（Alert提示） */
@property (nonatomic, assign) BOOL isShowWarning;

+ (instancetype)shareInstance;

/**
 设置单种崩溃保护类型

 @param type 需要保护的崩溃类型
 */
- (void)configProtectType:(HYExcepitionProtectorStrategy)type;

/**
 设置多种崩溃保护类型
 
 @param types 需要保护的崩溃类型数组
 */
- (void)configProtectTypes:(NSArray<HYExcepitionProtectorStrategy> *)types;

/**
 保护所有崩溃类型
 
 @mark 所有崩溃类型指已实现的上述类型，上述类型之外的崩溃不在保护之内；
 */
- (void)configAllProtectTypes;

/**
 开启保护
 */
- (void)startProtection;

@end



NS_ASSUME_NONNULL_END
