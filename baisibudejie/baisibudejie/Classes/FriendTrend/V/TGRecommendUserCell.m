//
//  TGRecommendUserCell.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/16.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGRecommendUserCell.h"
#import "TGRecommendUserM.h"

@interface TGRecommendUserCell()
@property (weak, nonatomic) IBOutlet UIImageView *headerImageV;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *fansCountLbl;
@end

@implementation TGRecommendUserCell

- (void)setUser:(TGRecommendUserM *)user{
    _user = user;
    self.screenNameLbl.text = user.screen_name;

    NSString *fansCount = nil;
    if (user.fans_count < 10000) {
        fansCount = [NSString stringWithFormat:@"%zd人关注", user.fans_count];
    } else {
        fansCount = [NSString stringWithFormat:@"%.1f万人关注", user.fans_count / 10000.0];
    }
    self.fansCountLbl.text = fansCount;
    
    [self.headerImageV sd_setImageWithURL:[NSURL URLWithString:user.header] placeholderImage:[UIImage imageNamed:@"defaultUserIcon"]];
}

@end
