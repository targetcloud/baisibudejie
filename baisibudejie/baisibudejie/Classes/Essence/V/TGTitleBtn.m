//
//  TGTitleBtn.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/8.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGTitleBtn.h"

@implementation TGTitleBtn


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.font = [UIFont systemFontOfSize:16];
//        [self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//        [self setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted{ //按钮就无法进入highlighted状态
    
}

@end
