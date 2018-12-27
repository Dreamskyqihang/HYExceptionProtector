## iOS应用Crash保护系统
### 方案：
参照简书：[iOS应用Crash保护系统](https://www.jianshu.com/p/eb713b1f22dc)
-------
### 功能：
对iOS APP进行崩溃保护，并对崩溃信息进行收集，可以根据需要上传到服务器，可以保护线上应用不闪退，并且收集到错误促使开发人员改正；该系统z从以下几个方面对APP进行保护
* ```unrecognized selector```引起的崩溃
* 容器类数据类型操作引起的崩溃
* 字符串操作引起的崩溃
* ```KVO```引起的崩溃
* ```NSTimer```引起的崩溃
* 非主线程刷新UI
* 野指针
* ```NSNotification```引起的崩溃

------
### 使用：
1. 导入头文件
```
#import "HYExcepitionProtector.h"
```
2.开启保护
```
[[HYExcepitionProtector shareInstance] configAllProtectTypes];
[[HYExcepitionProtector shareInstance] startProtection];
```

