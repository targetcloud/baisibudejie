//
//  TGFastBtn.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/7.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGFastBtn.h"

@implementation TGFastBtn

-(void)setupUI{
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setupUI];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.y = 0;
    self.imageView.centerX = self.width * 0.5;
    //self.imageView.width = 50;
    //self.imageView.height = self.imageView.width;
    self.titleLabel.y = self.height - self.titleLabel.height ;
    [self.titleLabel sizeToFit];
    self.titleLabel.centerX = self.width * 0.5;
}

@end
