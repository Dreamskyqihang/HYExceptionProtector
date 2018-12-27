//
//  HYExcepitionProtectedProtocol.h
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/10/22.
//  Copyright © 2018年 张鸿运. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HYExcepitionProtectedProtocol <NSObject>

@required
/**
 交换方法
 */
+ (void)hy_swizzleMethod;

@end

NS_ASSUME_NONNULL_END
