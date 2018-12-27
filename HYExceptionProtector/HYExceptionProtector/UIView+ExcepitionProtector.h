//
//  UIView+ExcepitionProtector.h
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/12/25.
//  Copyright © 2018 张鸿运. All rights reserved.
//

//======================================================
//   该分类为开发过程中,在子线程刷新UI提醒类
//   DEBUG模式下，会使程序崩溃，提示开发过程中在子线程刷新UI问题
//======================================================


#import <UIKit/UIKit.h>
#import "HYExcepitionProtectedProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ExcepitionProtector)<HYExcepitionProtectedProtocol>

@end

NS_ASSUME_NONNULL_END
