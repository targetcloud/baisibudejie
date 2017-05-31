//
//  TGTabBar.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/6.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGTabBar.h"
#import "TGPublishV.h"

@interface TGTabBar()
@property (nonatomic, weak) UIButton *publishButton;
@property (nonatomic, weak) UIControl *previousClickedTabBarBtn;
@end

@implementation TGTabBar

- (UIButton *)publishButton{
    if (_publishButton == nil) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"tabBar_publish_icon"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"tabBar_publish_click_icon"] forState:UIControlStateHighlighted];
        [btn sizeToFit];
        [btn addTarget:self action:@selector(publishButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        _publishButton = btn;
    }
    return _publishButton;
}

-(void) layoutSubviews{
    [super layoutSubviews];
    CGFloat btnW = self.width / (self.items.count + 1);
    CGFloat btnH = self.height;
    CGFloat x = 0;
    int i = 0;
    for (UIControl *tabBarBtn in self.subviews) {
        if ([tabBarBtn isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            if (i == 0 && _previousClickedTabBarBtn == nil) {
                _previousClickedTabBarBtn = tabBarBtn;
            }
            if (i == 2) {
                i += 1;
            }
            x = i * btnW;
            tabBarBtn.frame = CGRectMake(x, 0, btnW, btnH);
            i++;
            
            [tabBarBtn addTarget:self action:@selector(tabBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    self.publishButton.center = CGPointMake(self.width * 0.5, self.height * 0.5);//self.center (x = 207, y = 711.5)
}

- (void)tabBarButtonClick:(UIControl *)tabBarBtn{
    if (_previousClickedTabBarBtn == tabBarBtn) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TabBarButtonDidRepeatClickNotification object:nil];
    }
    _previousClickedTabBarBtn = tabBarBtn;
}

- (void)publishButtonClick{
    TGPublishV *publishV = [TGPublishV viewFromXIB];
    [[UIApplication sharedApplication].keyWindow addSubview:publishV];
    publishV.frame = [UIApplication sharedApplication].keyWindow.bounds;
}

@end
