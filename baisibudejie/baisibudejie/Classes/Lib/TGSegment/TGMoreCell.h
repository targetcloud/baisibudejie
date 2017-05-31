//
//  TGMoreCell.h
//  TGSegment
//
//  Created by targetcloud on 2017/4/18.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGSegmentConfig.h"

@interface TGMoreCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *menuLabel;
@property (nonatomic, strong) TGSegmentConfig *segmentConfig;
@end
