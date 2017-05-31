//
//  TGMoreLayout.h
//  TGSegment
//
//  Created by targetcloud on 2017/4/23.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef CGFloat(^HeightBlock)(NSIndexPath *indexPath , CGFloat width);
@interface TGMoreLayout : UICollectionViewLayout
@property (nonatomic, assign) NSInteger cols;
@property (nonatomic, assign) CGFloat minCellH;
@property (nonatomic, assign) CGFloat minimumLineSpacing;
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;
@property (nonatomic, assign) UIEdgeInsets sectionInset;
- (void)computeIndexCellHeightWithWidthBlock:(HeightBlock)block;
@end
