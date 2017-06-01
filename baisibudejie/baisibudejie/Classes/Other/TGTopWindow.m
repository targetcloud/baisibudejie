//
//  TGTopWindow.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/26.
//  Copyright © 2017年 targetcloud. All rights reserved.
//  Blog http://blog.csdn.net/callzjy
//  Mail targetcloud@163.com
//  Github https://github.com/targetcloud

#import "TGTopWindow.h"

@implementation TGTopWindow

static UIWindow *window_;

+ (void)initialize{
    window_ = [[UIWindow alloc] init];
    window_.rootViewController = [[UIViewController alloc] init];
    window_.frame = CGRectMake(0, 0, ScreenW, 20);
    window_.backgroundColor = [UIColor clearColor];
    window_.windowLevel = UIWindowLevelAlert;
    [window_ addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(windowClick)]];
}

+ (void)show{
    window_.hidden = NO;
}

+ (void)hide{
    window_.hidden = YES;
}

+ (void)windowClick{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [self searchScrollViewInView:window];
}

+ (void)searchScrollViewInView:(UIView *)superview{
    for (UIScrollView *subview in superview.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]] && subview.isShowingOnKeyWindow) {
            CGPoint offset = subview.contentOffset;
            offset.y = - subview.contentInset.top;
            [subview setContentOffset:offset animated:YES];
        }
        [self searchScrollViewInView:subview];
    }
}
@end
