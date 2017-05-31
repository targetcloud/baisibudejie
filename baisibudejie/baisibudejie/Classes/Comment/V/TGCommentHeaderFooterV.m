//
//  TGCommentHeaderFooterV.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/23.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGCommentHeaderFooterV.h"

@implementation TGCommentHeaderFooterV

-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.textLabel.textColor = [UIColor darkGrayColor];
        self.contentView.backgroundColor = [TGGrayColor(244) colorWithAlphaComponent:0.6];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.textLabel.font = [UIFont systemFontOfSize:13];
    self.textLabel.x = Margin;
}

@end
