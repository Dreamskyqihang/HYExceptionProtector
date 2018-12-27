//
//  NSObject+KVOCrashProtector.h
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/12/25.
//  Copyright © 2018 张鸿运. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KVOCrashProtector)

+ (void)hy_KVOCrashProtectorSwizzleMethod;

@end

NS_ASSUME_NONNULL_END
