//
//  XCApplicationHelper.h
//  XCApplicationHelperExample
//
//  Created by 樊小聪 on 2018/7/19.
//  Copyright © 2018年 樊小聪. All rights reserved.
//


/*
 *  备注：处理与App生命周期相关的代理方法的回调 🐾
 */

#import <Foundation/Foundation.h>

@interface XCApplicationHelper : NSObject

/**
 *  注册 Application，只有注册过的对象才可以监听 App 相关的生命周期方法的回调
 *
 *  @param obj 需要监听的对象
 *
 *  !!! ------- !!!
 *      注意：当对象被销毁时，需要注销监听
 *  !!! ------- !!!
 */
+ (void)registerApplication:(nonnull id)obj;

/**
 *  取消对 Application 的注册，该对象将不再监听 App 相关的生命周期方法的回调
 *
 *  @param obj 需要取消监听的对象
 */
+ (void)unregisterApplication:(nonnull id)obj;

@end
