//
//  TGCarouselImageView.h
//  baisibudejie
//
//  Created by targetcloud on 2017/6/1.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TGCarouselImageViewDelegate <NSObject>
- (void)didTapCarouselImageViewAtIndex:(NSInteger)index;
@end

typedef void (^DidTapCarouselImageViewAtIndexBlock)(NSInteger index);

@interface TGCarouselImageView : UIView
@property (nonatomic) UIViewContentMode imageContentMode;
@property (nonatomic, assign) NSTimeInterval autoPagingInterval;
@property (nonatomic, strong) UIColor *currentPageIndicatorTintColor;
@property (nonatomic, strong) UIColor *pageIndicatorTintColor;
@property (nonatomic, strong) UIImage *currentPageIndicatorImage;
@property (nonatomic, strong) UIImage *pageIndicatorImage;

+ (instancetype)tg_carouselImageViewWithFrame:(CGRect)frame imageArrary:(NSArray *)imageArrary;
+ (instancetype)tg_carouselImageViewWithFrame:(CGRect)frame imageArrary:(NSArray *)imageArrary describeArray:(NSArray *)describeArray;
+ (instancetype)tg_carouselImageViewWithFrame:(CGRect)frame imageArrary:(NSArray *)imageArrary describeArray:(NSArray *)describeArray placeholderImage:(UIImage *)placeholderImage;
+ (instancetype)tg_carouselImageViewWithFrame:(CGRect)frame imageArrary:(NSArray *)imageArrary describeArray:(NSArray *)describeArray placeholderImage:(UIImage *)placeholderImage delegate:(id<TGCarouselImageViewDelegate>)delegate;
+ (instancetype)tg_carouselImageViewWithFrame:(CGRect)frame imageArrary:(NSArray *)imageArrary describeArray:(NSArray *)describeArray placeholderImage:(UIImage *)placeholderImage block:(DidTapCarouselImageViewAtIndexBlock)block;
- (instancetype)initWithFrame:(CGRect)frame imageArrary:(NSArray *)imageArrary describeArray:(NSArray *)describeArray placeholderImage:(UIImage *)placeholderImage delegate:(id<TGCarouselImageViewDelegate>)delegate;
- (instancetype)initWithFrame:(CGRect)frame imageArrary:(NSArray *)imageArrary describeArray:(NSArray *)describeArray placeholderImage:(UIImage *)placeholderImage block:(DidTapCarouselImageViewAtIndexBlock)block;
@end
