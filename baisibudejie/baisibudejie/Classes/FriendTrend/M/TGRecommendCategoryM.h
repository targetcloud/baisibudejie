//
//  TGRecommendCategoryM.h
//  baisibudejie
//
//  Created by targetcloud on 2017/5/16.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGRecommendCategoryM : NSObject
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger currentPage;
@end
