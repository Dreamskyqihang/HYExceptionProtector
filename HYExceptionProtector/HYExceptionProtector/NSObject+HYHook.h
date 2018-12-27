//
//  NSObject+HYHook.h
//  HYUsersTraceRecordDemo
//
//  Created by 张鸿运 on 2018/10/17.
//  Copyright © 2018年 张鸿运. All rights reserved.
//


//===================================
//       该分类为提供交换方法的工具类
//===================================
#import <Foundation/Foundation.h>


/**
 交换某个类的两个实例方法

 @param cls              要交换的类
 @param originSelector   原方法
 @param swizzledSelector 要交换的方法
 */
void hy_swizzleInstanceMethodImplementation( Class cls, SEL originSelector, SEL swizzledSelector );

/**
 交换某个类的两个类方法
 
 @param cls              要交换的类
 @param originSelector   原方法
 @param swizzledSelector 要交换的方法
 */
void hy_swizzleClassMethodImplementation( Class cls, SEL originSelector, SEL swizzledSelector );


@interface NSObject (HYHook)

/**
 交换实例方法

 @param originSelector   原方法
 @param swizzledSelector 要交换的方法
 */
+ (void)hy_swizzleInstanceMethodImplementation:(SEL)originSelector withSEL:(SEL)swizzledSelector;

/**
 交换类方法
 
 @param originSelector   原方法
 @param swizzledSelector 要交换的方法
 */
+ (void)hy_swizzleClassMethodImplementation:(SEL)originSelector withSEL:(SEL)swizzledSelector;

@end
