//
//  XCApplicationHelper.m
//  XCApplicationHelperExample
//
//  Created by 樊小聪 on 2018/7/19.
//  Copyright © 2018年 樊小聪. All rights reserved.
//


/*
 *  备注：处理与App生命周期相关的代理方法的回调 🐾
 */

#import "XCApplicationHelper.h"

#import <objc/runtime.h>
#import <objc/message.h>
#import <UIKit/UIKit.h>
#import <XCMacros/XCMacros.h>

#define ADD_SELECTOR_PREFIX(__SELECTOR__) @selector(_xc_##__SELECTOR__)

#define SWIZZLE_DELEGATE_METHOD(__SELECTORSTRING__) \
Swizzle([delegate class], @selector(__SELECTORSTRING__), class_getClassMethod([XCApplicationHelper class], ADD_SELECTOR_PREFIX(__SELECTORSTRING__))); \

#define APPDELEGATE_METHOD_MSG_SEND(__SELECTOR__, __ARG1__, __ARG2__) \
for (id obj in XCApplicationHelperObjects) { \
id target = [obj nonretainedObjectValue];\
if ([target respondsToSelector:__SELECTOR__]) { \
[target performSelector:__SELECTOR__ withObject:__ARG1__ withObject:__ARG2__]; \
} \
}

#define SELECTOR_IS_EQUAL(__SELECTOR1__, __SELECTOR2__) \
Method m1 = class_getClassMethod([XCApplicationHelper class], __SELECTOR1__); \
IMP imp1 = method_getImplementation(m1); \
Method m2 = class_getInstanceMethod([self class], __SELECTOR2__); \
IMP imp2 = method_getImplementation(m2); \

#define DEF_APPDELEGATE_METHOD_CONTAIN_RESULT(__ARG1__, __ARG2__) \
BOOL result = YES; \
SEL xc_selector = NSSelectorFromString([NSString stringWithFormat:@"_xc_%@", NSStringFromSelector(_cmd)]); \
SELECTOR_IS_EQUAL(xc_selector, _cmd) \
if (imp1 != imp2) { \
result = !![self performSelector:xc_selector withObject:__ARG1__ withObject:__ARG2__]; \
} \
APPDELEGATE_METHOD_MSG_SEND(_cmd, __ARG1__, __ARG2__); \
return result; \

#define DEF_APPDELEGATE_METHOD(__ARG1__, __ARG2__) \
SEL xc_selector = NSSelectorFromString([NSString stringWithFormat:@"_xc_%@", NSStringFromSelector(_cmd)]); \
SELECTOR_IS_EQUAL(xc_selector, _cmd) \
if (imp1 != imp2) { \
[self performSelector:xc_selector withObject:__ARG1__ withObject:__ARG2__]; \
} \
APPDELEGATE_METHOD_MSG_SEND(_cmd, __ARG1__, __ARG2__); \


void Swizzle(Class class, SEL originalSelector, Method swizzledMethod)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    SEL swizzledSelector = method_getName(swizzledMethod);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod && originalMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
    class_addMethod(class,
                    swizzledSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
}


/// 替换掉 App 的代理方法
@implementation UIApplication (XCApplicationHelper)
- (void)helper_setDelegate:(id<UIApplicationDelegate>)delegate
{
    static dispatch_once_t delegateOnceToken;
    dispatch_once(&delegateOnceToken, ^{
BeginIgnoreClangWarning(-Wundeclared-selector)
        SWIZZLE_DELEGATE_METHOD(applicationDidFinishLaunching:);
        SWIZZLE_DELEGATE_METHOD(application: willFinishLaunchingWithOptions:);
        SWIZZLE_DELEGATE_METHOD(application: didFinishLaunchingWithOptions:);
        SWIZZLE_DELEGATE_METHOD(applicationDidBecomeActive:)
        SWIZZLE_DELEGATE_METHOD(applicationWillResignActive:)
        SWIZZLE_DELEGATE_METHOD(application: openURL: options:)
        SWIZZLE_DELEGATE_METHOD(application: handleOpenURL:)
        SWIZZLE_DELEGATE_METHOD(application: openURL: sourceApplication: annotation:)
        SWIZZLE_DELEGATE_METHOD(applicationDidReceiveMemoryWarning:)
        SWIZZLE_DELEGATE_METHOD(applicationWillTerminate:)
        SWIZZLE_DELEGATE_METHOD(applicationSignificantTimeChange:);
        SWIZZLE_DELEGATE_METHOD(application: didRegisterForRemoteNotificationsWithDeviceToken:)
        SWIZZLE_DELEGATE_METHOD(application: didFailToRegisterForRemoteNotificationsWithError:)
        SWIZZLE_DELEGATE_METHOD(application: didReceiveRemoteNotification:)
        SWIZZLE_DELEGATE_METHOD(application: didReceiveLocalNotification:)
        SWIZZLE_DELEGATE_METHOD(application: handleEventsForBackgroundURLSession: completionHandler:)
        SWIZZLE_DELEGATE_METHOD(application: handleWatchKitExtensionRequest: reply:)
        SWIZZLE_DELEGATE_METHOD(applicationShouldRequestHealthAuthorization:)
        SWIZZLE_DELEGATE_METHOD(applicationDidEnterBackground:)
        SWIZZLE_DELEGATE_METHOD(applicationWillEnterForeground:)
        SWIZZLE_DELEGATE_METHOD(applicationProtectedDataWillBecomeUnavailable:)
        SWIZZLE_DELEGATE_METHOD(applicationProtectedDataDidBecomeAvailable:)
        SWIZZLE_DELEGATE_METHOD(application: performFetchWithCompletionHandler:)
        SWIZZLE_DELEGATE_METHOD(application: didReceiveRemoteNotification: fetchCompletionHandler:)
EndIgnoreClangWarning
    });
    [self helper_setDelegate:delegate];
}
@end


/// 缓存已经需要监听的对象
static NSMutableArray<id> *XCApplicationHelperObjects;

BOOL XCApplicationHelperObjectIsRegistered(id x)
{
    return [objc_getAssociatedObject(x, &XCApplicationHelperObjectIsRegistered) ?: @YES boolValue];
}

@implementation XCApplicationHelper

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Swizzle([UIApplication class], @selector(setDelegate:), class_getInstanceMethod([UIApplication class], @selector(helper_setDelegate:)));
    });
}


#pragma mark - 🔓 👀 Public Method 👀

/**
 *  注册 Application，只有注册过的对象才可以监听 App 相关的生命周期方法的回调
 *
 *  @param obj 需要监听的对象
 */
+ (void)registerApplication:(nonnull id)obj
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        XCApplicationHelperObjects = [NSMutableArray new];
    });
    
    [XCApplicationHelperObjects addObject:[NSValue valueWithNonretainedObject:obj]];
    
    objc_setAssociatedObject(obj, &XCApplicationHelperObjectIsRegistered,
                             @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/**
 *  取消对 Application 的注册，该对象将不再监听 App 相关的生命周期方法的回调
 *
 *  @param obj 需要取消监听的对象
 */
+ (void)unregisterApplication:(nonnull id)obj
{
    for (int i = 0; i < XCApplicationHelperObjects.count ; i++) {
        NSValue *currentValue = XCApplicationHelperObjects[i];
        id currentObj = [currentValue nonretainedObjectValue];
        if (currentObj == nil || currentObj == obj) {
            [XCApplicationHelperObjects removeObject:currentValue];
            i--;
        }
    }
    
    //以安全的方式移除相关关联，而不是移除所有关联
    objc_setAssociatedObject(obj, &XCApplicationHelperObjectIsRegistered,
                             nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 🔒 👀 Privite Method 👀

#pragma mark - AppDelegate

BeginIgnorePerformSelectorLeaksWarning
+ (void)_xc_applicationDidFinishLaunching:(UIApplication *)application
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}

+ (BOOL)_xc_application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions
{
    DEF_APPDELEGATE_METHOD_CONTAIN_RESULT(application, launchOptions);
}

+ (BOOL)_xc_application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions
{
    DEF_APPDELEGATE_METHOD_CONTAIN_RESULT(application, launchOptions);
}

+ (void)_xc_applicationDidBecomeActive:(UIApplication *)application
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)_xc_applicationWillResignActive:(UIApplication *)application
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (BOOL)_xc_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options NS_AVAILABLE_IOS(9_0)
{
    BOOL result = YES;
    SEL xc_selector = NSSelectorFromString([NSString stringWithFormat:@"_xc_%@", NSStringFromSelector(_cmd)]);
    SELECTOR_IS_EQUAL(xc_selector, _cmd)
    if (!imp1 || !imp2) {
        return YES;
    }
    if (imp1 != imp2) {
        result = ((BOOL (*)(id, SEL, id, id, id))(void *)objc_msgSend)(self, xc_selector, app, url, options);
    }
    BOOL (*typed_msgSend)(id, SEL, id, id, id) = (void *)objc_msgSend;

    for (NSValue * obj in XCApplicationHelperObjects) {
        id target = [obj nonretainedObjectValue];
        if ([target respondsToSelector:_cmd]) {
            typed_msgSend(target, _cmd, app, url, options);
        }
    }
    return result;
}

+ (BOOL)_xc_application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    DEF_APPDELEGATE_METHOD_CONTAIN_RESULT(application, url);
}

+ (BOOL)ytxmodule_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = YES;
    SEL xc_selector = NSSelectorFromString([NSString stringWithFormat:@"_xc_%@", NSStringFromSelector(_cmd)]);
    SELECTOR_IS_EQUAL(xc_selector, _cmd)
    if (imp1 != imp2) {
        result = ((BOOL (*)(id, SEL, id, id, id, id))(void *)objc_msgSend)(self, xc_selector, application, url, sourceApplication, annotation);
    }
    BOOL (*typed_msgSend)(id, SEL, id, id, id, id) = (void *)objc_msgSend;
    
    for (NSValue * obj in XCApplicationHelperObjects) {
        id target = [obj nonretainedObjectValue];
        if ([target respondsToSelector:_cmd]) {
            typed_msgSend(target, _cmd, application, url, sourceApplication, annotation);
        }
    }
    return result;
}

+ (void)_xc_applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)_xc_applicationWillTerminate:(UIApplication *)application
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)_xc_applicationSignificantTimeChange:(UIApplication *)application
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)_xc_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken NS_AVAILABLE_IOS(3_0)
{
    DEF_APPDELEGATE_METHOD(application, deviceToken);
}
+ (void)_xc_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error NS_AVAILABLE_IOS(3_0)
{
    DEF_APPDELEGATE_METHOD(application, error);
}
+ (void)_xc_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo NS_AVAILABLE_IOS(3_0)
{
    DEF_APPDELEGATE_METHOD(application, userInfo);
}
+ (void)_xc_application:(UIApplication *)application didReceiveLocalNotification:(NSDictionary *)userInfo NS_AVAILABLE_IOS(3_0)
{
    DEF_APPDELEGATE_METHOD(application, userInfo);
}
+ (void)_xc_application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler NS_AVAILABLE_IOS(7_0)
{
    SEL xc_selector = NSSelectorFromString([NSString stringWithFormat:@"_xc_%@", NSStringFromSelector(_cmd)]);
    SELECTOR_IS_EQUAL(xc_selector, _cmd)
    if (imp1 != imp2) {
        ((void (*)(id, SEL, id, id, id))(void *)objc_msgSend)(self, xc_selector, application, identifier, completionHandler);
    }
    void (*typed_msgSend)(id, SEL, id, id, id) = (void *)objc_msgSend;
    
    for (NSValue * obj in XCApplicationHelperObjects) {
        id target = [obj nonretainedObjectValue];
        if ([target respondsToSelector:_cmd]) {
            typed_msgSend(target, _cmd, application, identifier, completionHandler);
        }
    }
}
+ (void)_xc_application:(UIApplication *)application handleWatchKitExtensionRequest:(nullable NSDictionary *)userInfo reply:(void(^)(NSDictionary * __nullable replyInfo))reply NS_AVAILABLE_IOS(8_2)
{
    SEL xc_selector = NSSelectorFromString([NSString stringWithFormat:@"_xc_%@", NSStringFromSelector(_cmd)]);
    SELECTOR_IS_EQUAL(xc_selector, _cmd)
    if (imp1 != imp2) {
        ((void (*)(id, SEL, id, id, id))(void *)objc_msgSend)(self, xc_selector, application, userInfo, reply);
    }
    void (*typed_msgSend)(id, SEL, id, id, id) = (void *)objc_msgSend;
    
    for (NSValue * obj in XCApplicationHelperObjects) {
        id target = [obj nonretainedObjectValue];
        if ([target respondsToSelector:_cmd]) {
            typed_msgSend(target, _cmd, application, userInfo, reply);
        }
    }
}
+ (void)_xc_applicationShouldRequestHealthAuthorization:(UIApplication *)application NS_AVAILABLE_IOS(9_0)
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)_xc_applicationDidEnterBackground:(UIApplication *)application NS_AVAILABLE_IOS(4_0)
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)_xc_applicationWillEnterForeground:(UIApplication *)application NS_AVAILABLE_IOS(4_0)
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)_xc_applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application NS_AVAILABLE_IOS(4_0)
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)_xc_applicationProtectedDataDidBecomeAvailable:(UIApplication *)application    NS_AVAILABLE_IOS(4_0)
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}

+ (void)_xc_application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    DEF_APPDELEGATE_METHOD(application, completionHandler);
}
EndIgnorePerformSelectorLeaksWarning

+ (void)_xc_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    SEL xc_selector = NSSelectorFromString([NSString stringWithFormat:@"_xc_%@", NSStringFromSelector(_cmd)]);
    SELECTOR_IS_EQUAL(xc_selector, _cmd)
    if (imp1 != imp2) {
        ((void (*)(id, SEL, id, id, id))(void *)objc_msgSend)(self, xc_selector, application, userInfo, completionHandler);
    }
    void (*typed_msgSend)(id, SEL, id, id, id) = (void *)objc_msgSend;
    
    for (NSValue * obj in XCApplicationHelperObjects) {
        id target = [obj nonretainedObjectValue];
        if ([target respondsToSelector:_cmd]) {
            typed_msgSend(target, _cmd, application, userInfo, completionHandler);
        }
    }
}


@end
