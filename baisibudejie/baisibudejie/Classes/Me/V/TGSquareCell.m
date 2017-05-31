//
//  TGSquareCell.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/7.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGSquareCell.h"
#import "TGSquareM.h"
#import <UIImageView+WebCache.h>

@interface TGSquareCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconV;
@property (weak, nonatomic) IBOutlet UILabel *nameV;
@end

@implementation TGSquareCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setItem:(TGSquareM *)item{
    _item = item;
    [_iconV sd_setImageWithURL:[NSURL URLWithString:item.icon]];
    _nameV.text = item.name;
}


@end
