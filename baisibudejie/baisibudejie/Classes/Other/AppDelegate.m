//
//  AppDelegate.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/5.
//  Copyright © 2017年 targetcloud. All rights reserved.
//  Blog http://blog.csdn.net/callzjy
//  Mail targetcloud@163.com
//  Github https://github.com/targetcloud

#import "AppDelegate.h"
//#import "TGMainVC.h"
#import "TGADVC.h"
#import "TGTopWindow.h"
#import <AFNetworking.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[TGADVC alloc] init];//[[TGMainVC alloc] init];
    [self.window makeKeyAndVisible];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;//View controller-based status bar appearance YES时[UIApplication sharedApplication].statusBarStyle此句无效果，去在用到时的VC中设置
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //[TGTopWindow show];//方式二，双击顶部状态栏，用自己定义的uiwindow盖在状态栏上，达到让显示在当前屏幕上的uiscrollview滚动到头部
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    if ([touches.anyObject locationInView : nil].y <= 20) {
//        TGLog(@"点击了状态栏")
//    }
//}


@end
