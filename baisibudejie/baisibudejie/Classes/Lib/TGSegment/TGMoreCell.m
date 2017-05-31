//
//  TGMoreCell.m
//  TGSegment
//
//  Created by targetcloud on 2017/4/18.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGMoreCell.h"

@implementation TGMoreCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    self.backgroundColor = selected ? self.segmentConfig.segSelectedColor: self.segmentConfig.showMoreCellBGColor ;
}

-(void)setSegmentConfig:(TGSegmentConfig *)segmentConfig{
    _segmentConfig = segmentConfig;
    self.menuLabel.textColor = self.segmentConfig.showMoreCellTextColor;
    self.menuLabel.font = self.segmentConfig.showMoreCellFont;
}

@end
