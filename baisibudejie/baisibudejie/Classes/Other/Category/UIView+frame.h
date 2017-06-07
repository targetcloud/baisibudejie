//
//  UIView+frame.h
//  baisibudejie
//
//  Created by targetcloud on 2017/3/6.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (frame)
@property CGFloat width;
@property CGFloat height;
@property CGFloat x;
@property CGFloat y;
@property CGFloat centerX;
@property CGFloat centerY;
@property CGSize size;
@property CGFloat left;
@property CGFloat right;
@property CGFloat top;
@property CGFloat bottom;
+ (instancetype)viewFromXIB;
- (BOOL)isShowingOnKeyWindow;
@end
