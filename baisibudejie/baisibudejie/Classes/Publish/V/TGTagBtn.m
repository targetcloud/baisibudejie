//
//  TGTagBtn.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/20.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGTagBtn.h"

@implementation TGTagBtn

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = TagBgColor;
        self.titleLabel.font = TagFont;
        [self setImage:[UIImage imageNamed:@"chose_tag_close_icon"] forState:UIControlStateNormal];
    }
    return self;
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state{
    [super setTitle:title forState:state];
    [self sizeToFit];
    self.width += 3  * TagMargin;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.x = TagMargin;
    self.imageView.x = CGRectGetMaxX(self.titleLabel.frame) + TagMargin;
}
@end
