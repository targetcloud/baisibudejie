//
//  TGRecommendCategoryM.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/16.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGRecommendCategoryM.h"

@implementation TGRecommendCategoryM
- (NSMutableArray *)users{
    if (!_users) {
        _users = [NSMutableArray array];
    }
    return _users;
}
@end
