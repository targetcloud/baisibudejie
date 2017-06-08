//
//  TGLayout.h
//  baisibudejie
//
//  Created by targetcloud on 2017/6/9.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TGLayout;

@protocol TGLayoutDelegate <NSObject>
@required
- (CGFloat)layout:(TGLayout *)layout heightForItemAtIndex:(NSUInteger)index itemWidth:(CGFloat)itemWidth;

@optional
- (CGFloat)columnCountInLayout:(TGLayout *)layout;
- (CGFloat)columnMarginInLayout:(TGLayout *)layout;
- (CGFloat)rowMarginInLayout:(TGLayout *)layout;
- (UIEdgeInsets)edgeInsetsInLayout:(TGLayout *)layout;
@end

@interface TGLayout : UICollectionViewLayout
@property (nonatomic, weak) id<TGLayoutDelegate> delegate;
@end
