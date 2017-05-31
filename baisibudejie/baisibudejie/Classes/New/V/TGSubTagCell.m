//
//  TGSubTagCell.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/6.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGSubTagCell.h"
#import "TGSubTagM.h"

@interface TGSubTagCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nameView;
@property (weak, nonatomic) IBOutlet UILabel *numView;
@end

@implementation TGSubTagCell

- (void)setFrame:(CGRect)frame{
    frame.size.height -= 1;
    [super setFrame:frame];
}

- (void)setItem:(TGSubTagM *)item{
    _item = item;
    _nameView.text = item.theme_name;
    [self resolveNum];
    [_iconView tg_setHeader:item.image_list];
}

- (void)resolveNum{
    NSInteger num = _item.sub_number.integerValue;
    _numView.text =  (num > 10000)? [[NSString stringWithFormat:@"%.1f万人订阅",num / 10000.0] stringByReplacingOccurrencesOfString:@".0" withString:@""] : [NSString stringWithFormat:@"%@人订阅",_item.sub_number] ;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
