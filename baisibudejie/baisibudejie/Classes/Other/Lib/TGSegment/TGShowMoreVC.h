//
//  TGShowMoreVC.h
//  TGSegment
//
//  Created by targetcloud on 2017/4/18.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGSegmentConfig.h"

@interface TGShowMoreVC : UICollectionViewController
@property (nonatomic, strong) NSArray <NSString *>* items;
- (instancetype)initWithConfig : (TGSegmentConfig *)segmentConfig;
@end
