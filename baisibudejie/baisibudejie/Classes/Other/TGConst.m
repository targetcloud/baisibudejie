//
//  TGConst.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/7.
//  Copyright © 2017年 targetcloud. All rights reserved.
//  Blog http://blog.csdn.net/callzjy
//  Mail targetcloud@163.com
//  Github https://github.com/targetcloud

#import <Foundation/Foundation.h>

CGFloat const TextHeightConstraint = 120;
CGFloat const Margin = 10;
CGFloat const TabBarH = 49;
CGFloat const NavMaxY = 64;
CGFloat const TitleVH = 35;
NSUInteger GIFCacheCountLimit = 30;

CGFloat const TagMargin = 5;
CGFloat const TagH = 25;

NSString  * const CommonURL = @"http://api.budejie.com/api/api_open.php";

//重复点击用于刷新
NSString  * const TabBarButtonDidRepeatClickNotification = @"TabBarButtonDidRepeatClickNotification";

NSString  * const TitleButtonDidRepeatClickNotification = @"TitleButtonDidRepeatClickNotification";

NSString  * const NavigationBarHiddenNotification = @"NavigationBarHiddenNotification";
NSString  * const NavigationBarShowNotification = @"NavigationBarShowNotification";
NSString  * const BackEssenceNotification = @"BackEssenceNotification";
NSString  * const AcrossEssenceNotification = @"AcrossEssenceNotification";

NSString  * const Boy = @"m";
NSString  * const Girl = @"f";
