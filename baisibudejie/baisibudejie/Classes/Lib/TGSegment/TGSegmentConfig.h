//
//  TGSegmentConfig.h
//  TGSegment
//
//  Created by targetcloud on 2017/4/18.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGSegmentConfig : NSObject
+ (instancetype)defaultConfig;

@property (nonatomic, strong) UIColor *segmentBarBGColor;//标题栏 的背景色
@property (nonatomic, assign) CGFloat segmentBarH;//标题栏的高度
@property (nonatomic, assign) BOOL isShowMore;//是否显示更多
@property (nonatomic, strong) UIColor *indicatorColor;//指示器颜色
@property (nonatomic, assign) CGFloat indicatorH;//指示器高度
@property (nonatomic, assign) CGFloat indicatorExtraW;//指示器左右扩展的宽度
@property (nonatomic, strong) UIColor *segNormalColor;//每个标签的正常颜色
@property (nonatomic, strong) UIColor *segSelectedColor;//每个标签选中的颜色
@property (nonatomic, strong) UIFont *segNormalFont;//每个标签的正常字体
@property (nonatomic, strong) UIFont *segSelectedFont;//每个标签的选中时的字体
@property (nonatomic, assign) CGFloat limitMargin;//标签间最小间距

@property (nonatomic, strong) UIColor *coverViewColor;//遮照颜色
@property (nonatomic, strong) UIColor *showMoreBGColor;//显示更多面板的背景色
@property (nonatomic, strong) UIColor *showMoreCellBGColor;//显示更多面板的每个单元格的背景色
@property (nonatomic, assign) NSInteger showMoreVCRowCount;//显示更多面板的每行个数
@property (nonatomic, assign) CGFloat showMoreCellMinH;//显示更多面板的每个单元格的最小高度
@property (nonatomic, strong) UIColor *showMoreCellTextColor;//显示更多面板的每个单元格的文本颜色
@property (nonatomic, strong) UIFont *showMoreCellFont;//显示更多面板的每个单元格的字体大小

@property (nonatomic, strong) UIColor *showMoreBtnBorderColor;//显示更多按钮的 边框颜色
@property (nonatomic, assign) CGFloat showMoreBtnborderW;//显示更多按钮的 边框宽度
@property (nonatomic, strong) UIColor *showMoreBtnTitleColor;//显示更多按钮的 标题颜色
@property (nonatomic, strong) UIColor *showMoreBtnBGColor;//显示更多按钮的 背景颜色
@property (nonatomic, strong) UIFont *showMoreBtnTitleFont;//显示更多按钮的 标题字体大小
@property (nonatomic, assign) BOOL isShowMoreBtnlineView;//是否显示更多按钮的 分割线
@property (nonatomic, assign) CGFloat showMoreBtnlineViewH;//显示更多按钮的 分割线的高度
@property (nonatomic, strong) UIColor *showMoreBtnlineViewColor;//显示更多按钮的 分割线的颜色

- (TGSegmentConfig *(^)(UIColor *color))barBGColor;
- (TGSegmentConfig *(^)(BOOL isShow))showMore;
- (TGSegmentConfig *(^)(UIColor *color))indicateColor;
- (TGSegmentConfig *(^)(CGFloat height))indicateH;
- (TGSegmentConfig *(^)(CGFloat width)) indicateExtraW;
- (TGSegmentConfig *(^)(UIColor *color))normalColor;
- (TGSegmentConfig *(^)(UIColor *color))selectedColor;
- (TGSegmentConfig *(^)(UIFont *font))normalFont;
- (TGSegmentConfig *(^)(UIFont *font))selectedFont;
- (TGSegmentConfig *(^)(CGFloat margin))margin;
- (TGSegmentConfig *(^)(CGFloat height))barH;
- (TGSegmentConfig *(^)(UIColor *color))moreBGColor;
- (TGSegmentConfig *(^)(UIColor *color))moreCellBGColor;
- (TGSegmentConfig *(^)(CGFloat count))moreVCRowCount;
- (TGSegmentConfig *(^)(CGFloat height))moreCellMinH;
- (TGSegmentConfig *(^)(UIColor *color))moreBtnBorderColor;
- (TGSegmentConfig *(^)(CGFloat width)) moreBtnborderW;
- (TGSegmentConfig *(^)(UIColor *color))moreBtnTitleColor;
- (TGSegmentConfig *(^)(UIColor *color))moreBtnBGColor;
- (TGSegmentConfig *(^)(UIFont *font))moreBtnTitleFont;
- (TGSegmentConfig *(^)(BOOL isShow))showMoreBtnlineView;
- (TGSegmentConfig *(^)(CGFloat height))moreBtnlineViewH;
- (TGSegmentConfig *(^)(UIColor *color))moreBtnlineViewColor;
- (TGSegmentConfig *(^)(UIColor *color))coverColor;
- (TGSegmentConfig *(^)(UIColor *color))moreCellTextColor;
- (TGSegmentConfig *(^)(UIFont *font))moreCellFont;

@end
