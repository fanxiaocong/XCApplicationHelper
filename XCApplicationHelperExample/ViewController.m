//
//  ViewController.m
//  XCApplicationHelperExample
//
//  Created by 樊小聪 on 2018/7/19.
//  Copyright © 2018年 樊小聪. All rights reserved.
//

#import "ViewController.h"
#import "XCApplicationHelper.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [XCApplicationHelper registerApplication:self];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"Receive BecomeActive");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"Receive ResignActive");
}

@end
