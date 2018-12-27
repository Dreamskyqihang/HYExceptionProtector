//
//  HYExcepitionCollector.m
//  HYExceptionProtector
//
//  Created by 张鸿运 on 2018/10/22.
//  Copyright © 2018年 张鸿运. All rights reserved.
//

// 打印异常信息的标记
#define ExcepitionHappenedEnd   @"================================================================"
#define ExcepitionHappenedStart @"========================⚠️⚠️⚠️⚠️⚠️⚠️⚠️========================="
// 发生异常的通知
#define ExcepitionHappenedNotification @"ExcepitionHappenedNotification"

#define kErrorName        @"errorName"
#define kErrorReason      @"errorReason"
#define kErrorPlace       @"errorPlace"
#define kCallStackSymbols @"callStackSymbols"
#define kException        @"exception"

#ifdef DEBUG
#define HYLog(...) NSLog(@"%@",[NSString stringWithFormat:__VA_ARGS__])
#else
#define HYLog(...)
#endif

#import "HYExcepitionCollector.h"

#import <UIKit/UIKit.h>
void hy_handleErrorWithException(NSException * exception)
{
    [HYExcepitionCollector handleErrorWithException:exception];
}

@implementation HYExcepitionCollector

/**
 简化堆栈信息

 @param callStackSymbols 详细堆栈信息
 @return 简化之后的堆栈信息
 */
+ (NSString *)getMainCallStackSymbolMessageWithCallStackSymbols:(NSArray<NSString *> *)callStackSymbols
{
    // mainCallStackSymbolMsg的格式为   +[类名 方法名]  或者 -[类名 方法名]
    __block NSString *mainCallStackSymbolMsg = nil;
    
    // 匹配出来的格式为 +[类名 方法名]  或者 -[类名 方法名]
    NSString *regularExpStr = @"[-\\+]\\[.+\\]";
    
    
    NSRegularExpression *regularExp = [[NSRegularExpression alloc] initWithPattern:regularExpStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    for (int index = 2; index < callStackSymbols.count; index++) {
        
        NSString *callStackSymbol = callStackSymbols[index];
        [regularExp enumerateMatchesInString:callStackSymbol
                                     options:NSMatchingReportProgress
                                       range:NSMakeRange(0, callStackSymbol.length)
                                  usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                                      
                                      if (result) {
                                          NSString *tempCallStackSymbolMsg = [callStackSymbol substringWithRange:result.range];

                                          NSString *className = [tempCallStackSymbolMsg componentsSeparatedByString:@" "].firstObject;
                                          className           = [className componentsSeparatedByString:@"["].lastObject;
                                          
                                          NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(className)];
                                          if (![className hasSuffix:@")"] && bundle == [NSBundle mainBundle]) {
                                              mainCallStackSymbolMsg = tempCallStackSymbolMsg;
                                              
                                          }
                                          *stop = YES;
                                      }
                                      
                                  }];
        
        if (mainCallStackSymbolMsg.length) break;
        
    }
    
    return mainCallStackSymbolMsg;
}


+ (void)handleErrorWithException:(NSException *)exception
{
    // 堆栈数据
    NSArray *callStackSymbolsArr     = [NSThread callStackSymbols];
    // 获取在哪个类的哪个方法中实例化的数组  字符串格式 -[类名 方法名]  或者 +[类名 方法名]
    NSString *mainCallStackSymbolMsg = [self getMainCallStackSymbolMessageWithCallStackSymbols:callStackSymbolsArr];
    
    if (mainCallStackSymbolMsg == nil)  mainCallStackSymbolMsg = @"崩溃方法定位失败,请您查看函数调用栈来排查错误原因";
        
    
    NSString *errorName   = exception.name;
    NSString *errorReason = exception.reason;
    // errorReason 可能为 -[__NSCFConstantString avoidCrashCharacterAtIndex:]: Range or index out of bounds
    errorReason           = [errorReason stringByReplacingOccurrencesOfString:@"avoidCrash" withString:@""];
    
    // 拼接错误信息
    NSString *errorPlace      = [NSString stringWithFormat:@"Error Place:%@",mainCallStackSymbolMsg];
    NSString *logErrorMessage = [NSString stringWithFormat:@"\n\n%@\n\n%@\n%@\n%@\n",ExcepitionHappenedStart, errorName, errorReason, errorPlace];
    logErrorMessage           = [NSString stringWithFormat:@"%@\n\n%@\n\n",logErrorMessage,ExcepitionHappenedEnd];
    
    HYLog(@"%@",logErrorMessage);
    
#if DEBUG
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:errorName
                                                                     message:errorReason
                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"好"
                                                style:UIAlertActionStyleDefault
                                              handler:nil]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVC
                                                                                 animated:YES
                                                                               completion:nil];
#endif
    
    
    NSDictionary *errorInfoDic = @{
                                   kErrorName        : errorName,
                                   kErrorReason      : errorReason,
                                   kErrorPlace       : errorPlace,
                                   kException        : exception,
                                   kCallStackSymbols : callStackSymbolsArr
                                   };
    
    // 将错误信息放在字典里，用通知的形式发送出去
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ExcepitionHappenedNotification object:nil userInfo:errorInfoDic];
        
    });
}

@end
