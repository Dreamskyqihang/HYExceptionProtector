//
//  NSObject+UnrecognizedSelectorProtector.h
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/12/19.
//  Copyright © 2018 张鸿运. All rights reserved.
//

//====================================================
//   该分类为防止unrecognized selector引起的崩溃的分类
//====================================================
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (UnrecognizedSelectorProtector)

+ (void)hy_UnrecognizedSelectorProtectorSwizzleMethod;

@end

NS_ASSUME_NONNULL_END
