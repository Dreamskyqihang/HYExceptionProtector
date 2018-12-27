//
//  HYExcepitionCollector.h
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/10/22.
//  Copyright © 2018年 张鸿运. All rights reserved.
//

#import <Foundation/Foundation.h>


void hy_handleErrorWithException(NSException * exception);


NS_ASSUME_NONNULL_BEGIN

@interface HYExcepitionCollector : NSObject

/**
 处理异常信息
 
 @param exception 异常
 */
+ (void)handleErrorWithException:(NSException *)exception;

@end

NS_ASSUME_NONNULL_END
