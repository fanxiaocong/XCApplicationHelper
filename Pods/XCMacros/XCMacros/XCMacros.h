//
//  XCMacros.h
//  XCMacrosExample
//
//  Created by 樊小聪 on 2017/9/28.
//  Copyright © 2017年 樊小聪. All rights reserved.
//


/*
 *  备注：常用工具宏文件 🐾
 */

#ifndef UtilsMacros_h
#define UtilsMacros_h

#import <UIKit/UIKit.h>


#pragma mark - 👀 日志输出 👀 💤
/* 🐖 ***************************** 🐖 日志输出 🐖 *****************************  🐖 */
#if DEBUG
#define DLog(format, ...) do {                                             \
fprintf(stderr, "<%s : line(%d)> %s\n",     \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
__LINE__, __func__);                        \
printf("%s\n", [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String]);           \
fprintf(stderr, "-------------------\n");   \
} while (0)
#else
#define DLog(format, ...) nil
#endif
/* 🐖 ***************************** 🐖 日志输出 🐖 *****************************  🐖 */


#pragma mark - 👀 强弱引用 👀 💤
/* 🐖 ***************************** 🐖 强弱引用 🐖 *****************************  🐖 */
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif
/* 🐖 ***************************** 🐖 强弱引用 🐖 *****************************  🐖 */


#pragma mark - 👀 设备型号 👀 💤
/* 🐖 ***************************** 🐖 设备型号 🐖 *****************************  🐖 */

/** 判断是否是iPhone4、iPhone5、iPhone6、iPhone6p 竖屏模式 */
#define IS_IPHONE4              ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

#define IS_IPHONE5              ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define IS_IPHONE6              ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)

#define IS_IPHONE6P              ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define IS_IPHONEX              ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

/// 判断是否是 iPhone
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
/// 判断是否是 iPad
#define IS_IPAD (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad)

/// 横屏模式
//  iPad Air  2048×1536
#define IS_IPAD_AIR              ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(2048, 1536), [[UIScreen mainScreen] currentMode].size) : NO)

//  iPad Pro  2732x2048
#define IS_IPAD_RPO              ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(2732, 2048), [[UIScreen mainScreen] currentMode].size) : NO)

/* 🐖 ***************************** 🐖 设备型号 🐖 *****************************  🐖 */



#pragma mark - 👀 系统版本 👀 💤
/* 🐖 ***************************** 🐖 系统版本 🐖 *****************************  🐖 */
#define IS_EQUAL_OR_LATER_IOS(version)  ([UIDevice currentDevice].systemVersion.floatValue >= (version))

#define iOS7_OR_LATER   (IS_EQUAL_OR_LATER_IOS(7.0))
#define iOS8_OR_LATER   (IS_EQUAL_OR_LATER_IOS(8.0))
#define iOS9_OR_LATER   (IS_EQUAL_OR_LATER_IOS(9.0))
#define iOS10_OR_LATER  (IS_EQUAL_OR_LATER_IOS(10.0))
#define iOS11_OR_LATER  (IS_EQUAL_OR_LATER_IOS(11.0))
/* 🐖 ***************************** 🐖 系统版本 🐖 *****************************  🐖 */


#pragma mark - 👀 忽略系统警告 👀 💤
/* 🐖 ***************************** 🐖 忽略系统警告 🐖 *****************************  🐖 */
#define ArgumentToString(macro) #macro
#define ClangWarningConcat(warning_name) ArgumentToString(clang diagnostic ignored warning_name)

// 参数可直接传入 clang 的 warning 名，warning 列表参考：http://fuckingclangwarnings.com/
#define BeginIgnoreClangWarning(warningName) _Pragma("clang diagnostic push") _Pragma(ClangWarningConcat(#warningName))
#define EndIgnoreClangWarning _Pragma("clang diagnostic pop")

/// 忽略 内存泄漏 警告
#define BeginIgnorePerformSelectorLeaksWarning BeginIgnoreClangWarning(-Warc-performSelector-leaks)
#define EndIgnorePerformSelectorLeaksWarning EndIgnoreClangWarning

/// 忽略 指针类型不兼容 警告
#define BeginIgnoreIncompatiblePointerTypesWarning BeginIgnoreClangWarning(-Wincompatible-pointer-types)
#define EndIgnoreIncompatiblePointerTypesWarning EndIgnoreClangWarning

/// 忽略 循环引用 警告
#define BeginIgnoreArcRetainCyclesWarning BeginIgnoreClangWarning(-Warc-retain-cycles)
#define EndIgnoreArcRetainCyclesWarning EndIgnoreClangWarning

/// 忽略 变量未使用 警告
#define BeginIgnoreUnusedVariableWarning BeginIgnoreClangWarning(-Wunused-variable)
#define EndIgnoreUnusedVariableWarning EndIgnoreClangWarning

/// 忽略 方法弃用 警告
#define BeginIgnoreDeprecatedWarning BeginIgnoreClangWarning(-Wdeprecated-declarations)
#define EndIgnoreDeprecatedWarning EndIgnoreClangWarning
/* 🐖 ***************************** 🐖 忽略系统警告 🐖 *****************************  🐖 */



#pragma mark - 👀 尺寸 👀 💤
/* 🐖 ***************************** 🐖 尺寸 🐖 *****************************  🐖 */
/// 状态栏高度
#define STARTUS_BAR_HEIGHT       (IS_IPHONEX ? 44.f : 20.f)

/// navBar方式
#define NAVIGATION_BAR_HEIGHT    44

/// tabBar高度
#define TAB_BAR_HEIGHT           (IS_IPHONEX ? (49.f+34.f) : 49.f)

/// 状态栏 和 navBar 的高度
#define STATUS_AND_NAVIGATION_BAR_HEIGHT    (STARTUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT)

/// 屏幕的宽高
#define SCREEN_RECT   [UIScreen mainScreen].bounds
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width

/// 根据给定的宽度（基于 ipone6），获取实际的宽度
static inline CGFloat FetchCurrentWidthFromIphone6Width(CGFloat width)
{
    return SCREEN_WIDTH / 375.0 * width;
}

/// 根据给定的高度（基于 ipone6），获取实际的高度
static inline CGFloat FetchCurrentHeightFromIphone6Height(CGFloat height)
{
    return SCREEN_HEIGHT / 667.0 * height;
}

/* 🐖 ***************************** 🐖 尺寸 🐖 *****************************  🐖 */




#pragma mark - 👀 其他 👀 💤
/* 🐖 ***************************** 🐖 其他 🐖 *****************************  🐖 */

#define PropertyDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

/// 通知中心
#define NOTIFICATION_CENTER    ([NSNotificationCenter defaultCenter])

/// App代理
#define APPLICATION_DELEGATE   ((AppDelegate *)[[UIApplication sharedApplication] delegate])

/// userDefaults
#define USER_DEFAULTS          ([NSUserDefaults standardUserDefaults])

/// NSFileManager
#define FILE_MANAGER           ([NSFileManager defaultManager])

/// 角度转弧度
#define DEGRESS_TO_RADIAN(d)        ((d) * M_PI / 180)
/// 弧度转角度
#define RADIAN_TO_DEGRESS(radian)   ((radian) * 180 / M_PI)

/// 判空
#define NULL_CLASS(object)  ((object) ?: @"")
/* 🐖 ***************************** 🐖 其他 🐖 *****************************  🐖 */


#pragma mark - 👀 懒加载 👀 💤
/* 🐖 ***************************** 🐖 懒加载  🐖 *****************************  🐖 */
#define LazyLoadMethod(variable)    \
- (NSMutableArray *)variable \
{   \
if (!_##variable)  \
{   \
_##variable = [NSMutableArray array];  \
}   \
return _##variable;    \
}
/* 🐖 ***************************** 🐖 懒加载  🐖 *****************************  🐖 */



#pragma mark - 👀 单例 👀 💤
/* 🐖 ***************************** 🐖 单例 🐖 *****************************  🐖 */// .h文件的实现
#define SingletonH(methodName) + (instancetype)shared##methodName;

// .m文件的实现
#if __has_feature(objc_arc) // 是ARC
#define SingletonM(methodName) \
static id _instace = nil; \
+ (id)allocWithZone:(struct _NSZone *)zone \
{ \
if (_instace == nil) { \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instace = [super allocWithZone:zone]; \
}); \
} \
return _instace; \
} \
\
- (id)init \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instace = [super init]; \
}); \
return _instace; \
} \
\
+ (instancetype)shared##methodName \
{ \
return [[self alloc] init]; \
} \
+ (id)copyWithZone:(struct _NSZone *)zone \
{ \
return _instace; \
} \
\
+ (id)mutableCopyWithZone:(struct _NSZone *)zone \
{ \
return _instace; \
}

#else // 不是ARC

#define SingletonM(methodName) \
static id _instace = nil; \
+ (id)allocWithZone:(struct _NSZone *)zone \
{ \
if (_instace == nil) { \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instace = [super allocWithZone:zone]; \
}); \
} \
return _instace; \
} \
\
- (id)init \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instace = [super init]; \
}); \
return _instace; \
} \
\
+ (instancetype)shared##methodName \
{ \
return [[self alloc] init]; \
} \
\
- (oneway void)release \
{ \
\
} \
\
- (id)retain \
{ \
return self; \
} \
\
- (NSUInteger)retainCount \
{ \
return 1; \
} \
+ (id)copyWithZone:(struct _NSZone *)zone \
{ \
return _instace; \
} \
\
+ (id)mutableCopyWithZone:(struct _NSZone *)zone \
{ \
return _instace; \
}

#endif
/* 🐖 ***************************** 🐖 单例 🐖 *****************************  🐖 */



#pragma mark - 👀 Dispatch 函数 👀 💤
/* 🐖 ***************************** 🐖 Dispatch 函数 🐖 *****************************  🐖 */
/// 异步纯种操作
static inline void DispatchAscyncOnGloabalQueue(void(^block)())
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        if (block)
        {
            block();
        }
    });
}

/// 回归主纯种操作
static inline void DispatchAscyncOnMainQueue(void(^block)())
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (block)
        {
            block();
        }
    });
}

/// 延时操作
static inline void DispatchAfter(int64_t time, void(^block)())
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (block)
        {
            block();
        }
    });
}
/* 🐖 ***************************** 🐖 Dispatch 函数 🐖 *****************************  🐖 */

#endif /* XCMacros_h */


