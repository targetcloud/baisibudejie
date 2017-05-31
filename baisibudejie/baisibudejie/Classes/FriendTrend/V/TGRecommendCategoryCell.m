//
//  TGRecommendCategoryCell.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/16.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGRecommendCategoryCell.h"
#import "TGRecommendCategoryM.h"

@interface TGRecommendCategoryCell()
@property (weak, nonatomic) IBOutlet UIView *selectedIndicator;
@end

@implementation TGRecommendCategoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = TGGrayColor(244);
    self.selectedIndicator.backgroundColor = TGColor(219, 21, 26);
    self.textLabel.font = [UIFont systemFontOfSize:14];
}

- (void)setCategory:(TGRecommendCategoryM *)category{
    _category = category;
    self.textLabel.text = category.name;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.textLabel.y = 2;
    self.textLabel.height = self.contentView.height - 2 * self.textLabel.y;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.selectedIndicator.hidden = !selected;
    self.textLabel.textColor = selected ? self.selectedIndicator.backgroundColor : TGGrayColor(78);
}

@end
