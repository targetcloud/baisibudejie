//
//  TGSegmentBar.h
//  TGSegment
//
//  Created by targetcloud on 2017/4/18.
//  Copyright © 2017年 targetcloud. All rights reserved.
//  Blog http://blog.csdn.net/callzjy
//  Mail targetcloud@163.com
//  Github https://github.com/targetcloud

#import <UIKit/UIKit.h>
#import "TGSegmentConfig.h"

@class TGSegmentBar;
@protocol TGSegmentBarDelegate <NSObject>//代理的定义 1
- (void)segmentBar: (TGSegmentBar *)segmentBar didSelectIndex: (NSInteger)toIndex fromIndex: (NSInteger)fromIndex;
@end

@interface TGSegmentBar : UIView
@property (nonatomic, weak) id<TGSegmentBarDelegate> delegate;//代理的定义 2
+ (instancetype)segmentBarWithFrame: (CGRect)frame config: (TGSegmentConfig *)config parentView: (UIView *)parentV;
- (void)updateViewWithConfig: (void(^)(TGSegmentConfig *config))configBlock;
@property (nonatomic, strong,readonly) TGSegmentConfig * segmentConfig;
@property (nonatomic, strong) NSArray<NSString *> *segmentModels;
@property (nonatomic, assign) NSInteger selectedIndex;//供外界赋值，反向修改头部选中的标签
@property (nonatomic,weak) UIView * parentV;//TGSementBarVC的view，可以通过类方法（20行）通过参数传入，若是通过对象方法创建，那么还需单独设置parentV，如果不设置，那么当bar在titleview时collectionview的cell不能响应点击
@end
