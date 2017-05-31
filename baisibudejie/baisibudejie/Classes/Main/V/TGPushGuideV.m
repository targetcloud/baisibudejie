//
//  TGPushGuideV.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/17.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGPushGuideV.h"

@implementation TGPushGuideV

+ (void)show{
    NSString *key = @"CFBundleShortVersionString";
    
    // 获得当前软件的版本号
    NSString *currentVersion = [NSBundle mainBundle].infoDictionary[key];
    // 获得沙盒中存储的版本号
    NSString *sanboxVersion = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    
    if (![currentVersion isEqualToString:sanboxVersion]) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        
        TGPushGuideV *guideView = [TGPushGuideV viewFromXIB];
        guideView.frame = window.bounds;
        [window addSubview:guideView];
        
        // 存储版本号
        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (IBAction)close {
    [self removeFromSuperview];
}

@end
