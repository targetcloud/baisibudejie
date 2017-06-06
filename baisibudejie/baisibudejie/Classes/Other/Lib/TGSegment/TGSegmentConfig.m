//
//  TGSegmentConfig.m
//  TGSegment
//
//  Created by targetcloud on 2017/4/18.
//  Copyright © 2017年 targetcloud. All rights reserved.
//  Blog http://blog.csdn.net/callzjy
//  Mail targetcloud@163.com
//  Github https://github.com/targetcloud

#import "TGSegmentConfig.h"

@implementation TGSegmentConfig

+ (instancetype)defaultConfig {
    return [[TGSegmentConfig alloc] init];
}

- (UIColor *)segmentBarBGColor {
    if (!_segmentBarBGColor) {
        _segmentBarBGColor = [UIColor clearColor];
    }
    return _segmentBarBGColor;
}

- (UIColor *)indicatorColor {
    if (!_indicatorColor) {
        _indicatorColor = [UIColor colorWithRed:249 / 255.0 green:89 / 255.0 blue:59 / 255.0 alpha:1];
    }
    return _indicatorColor;
}

- (CGFloat)indicatorH {
    if (_indicatorH <= 0) {
        _indicatorH = 2;
    }
    return _indicatorH;
}

-(UIColor *)segNormalColor {
    if (!_segNormalColor) {
        _segNormalColor = [UIColor darkGrayColor];
    }
    return _segNormalColor;
}

-(UIColor *)segSelectedColor {
    if (!_segSelectedColor) {
        _segSelectedColor = [UIColor colorWithRed:249 / 255.0 green:89 / 255.0 blue:59 / 255.0 alpha:1];
    }
    return _segSelectedColor;
}

- (UIFont *)segNormalFont {
    if (!_segNormalFont) {
        _segNormalFont = [UIFont systemFontOfSize:12];
    }
    return _segNormalFont;
}

- (UIFont *)segSelectedFont {
    if (!_segSelectedFont) {
        _segSelectedFont = [UIFont systemFontOfSize:12];
    }
    return _segSelectedFont;
}

- (CGFloat)limitMargin {
    if (_limitMargin <= 0) {
        _limitMargin = 8;
    }
    return _limitMargin;
}

- (CGFloat)indicatorExtraW {
    if (_indicatorExtraW <= 0) {
        _indicatorExtraW = 8;
    }
    return _indicatorExtraW;
}

- (CGFloat)segmentBarH {
    if (_segmentBarH <= 0) {
        _segmentBarH = 35;
    }
    return _segmentBarH;
}

- (NSInteger) showMoreVCRowCount{
    if (_showMoreVCRowCount <= 0) {
        _showMoreVCRowCount = 3;
    }
    return _showMoreVCRowCount;
}

-(CGFloat) showMoreCellMinH{
    if (_showMoreCellMinH <= 0) {
        _showMoreCellMinH = 25;
    }
    return _showMoreCellMinH;
}

- (UIColor *)showMoreBtnBorderColor{//显示更多按钮的 边框颜色
    if (!_showMoreBtnBorderColor) {
        _showMoreBtnBorderColor = [UIColor colorWithRed:249 / 255.0 green:89 / 255.0 blue:59 / 255.0 alpha:1];
    }
    return _showMoreBtnBorderColor;
}

- (UIColor *)showMoreBGColor{//显示更多面板的背景色
    if (!_showMoreBGColor) {
        _showMoreBGColor = [UIColor colorWithRed:203 / 255.0 green:203 / 255.0 blue:203 / 255.0 alpha:1];
    }
    return _showMoreBGColor;
}

- (UIColor *)showMoreCellBGColor{//显示更多面板
    if (!_showMoreCellBGColor) {
        _showMoreCellBGColor = [UIColor colorWithRed:230 / 255.0 green:230 / 255.0 blue:230 / 255.0 alpha:1];
    }
    return _showMoreCellBGColor;
}

- (UIColor *)coverViewColor{//遮照颜色
    if (!_coverViewColor) {
        _coverViewColor = [UIColor colorWithRed:222 / 255.0 green:222 / 255.0 blue:222 / 255.0 alpha:0.9];
    }
    return _coverViewColor;
}

- (CGFloat)showMoreBtnborderW{//显示更多按钮的 边框宽度
    if (_showMoreBtnborderW < 0) {
        _showMoreBtnborderW = 0;
    }
    return _showMoreBtnborderW;
}

- (UIColor *)showMoreBtnTitleColor{//显示更多按钮的 标题颜色
    if (!_showMoreBtnTitleColor) {
        _showMoreBtnTitleColor = [UIColor darkGrayColor];
    }
    return _showMoreBtnTitleColor;
}

- (UIColor *)showMoreBtnBGColor{//显示更多按钮的 背景颜色
    if (!_showMoreBtnBGColor) {
        _showMoreBtnBGColor = [UIColor clearColor];
    }
    return _showMoreBtnBGColor;
}

- ( UIFont *)showMoreBtnTitleFont{//显示更多按钮的 标题字体大小
    if (!_showMoreBtnTitleFont) {
        _showMoreBtnTitleFont = [UIFont systemFontOfSize:12];
    }
    return _showMoreBtnTitleFont;
}

- (CGFloat)showMoreBtnlineViewH{//显示更多按钮的 分割线的高度
    if (_showMoreBtnlineViewH <= 0) {
        _showMoreBtnlineViewH = 9;
    }
    return _showMoreBtnlineViewH;
}

- (UIColor *)showMoreBtnlineViewColor{//显示更多按钮的 分割线的颜色
    if (!_showMoreBtnlineViewColor) {
        _showMoreBtnlineViewColor = [UIColor lightGrayColor];
    }
    return _showMoreBtnlineViewColor;
}

- (UIColor *)showMoreCellTextColor{//显示更多面板的每个单元格的文本颜色
    if (!_showMoreCellTextColor) {
        _showMoreCellTextColor = [UIColor darkGrayColor];
    }
    return _showMoreCellTextColor;
}

- (UIFont *)showMoreCellFont{//显示更多面板的每个单元格的字体大小
    if (!_showMoreCellFont) {
        _showMoreCellFont = [UIFont systemFontOfSize:12];
    }
    return _showMoreCellFont;
}

#pragma mark - 以下为链式配置
- (TGSegmentConfig *(^)(UIColor *))normalColor {
    return ^(UIColor *color){
        self.segNormalColor = color;
        return self;
    };
}

-(TGSegmentConfig *(^)(UIColor *))selectedColor {
    return ^(UIColor *color){
        self.segSelectedColor = color;
        return self;
    };
}

- (TGSegmentConfig *(^)(UIColor *))barBGColor{
    return ^(UIColor *color){
        self.segmentBarBGColor = color;
        return self;
    };
}

- (TGSegmentConfig *(^)(CGFloat height))barH{
    return ^(CGFloat height){
        self.segmentBarH = height;
        return self;
    };
}

- (TGSegmentConfig *(^)(BOOL ))showMore{
    return ^(BOOL isShow){
        self.isShowMore = isShow;
        return self;
    };
}

- (TGSegmentConfig *(^)(BOOL isCircle))circleScroll{
    return ^(BOOL isCircle){
        self.isCircleScroll = isCircle;
        return self;
    };
}

- (TGSegmentConfig *(^)(UIColor *))indicateColor{
    return ^(UIColor *color){
        self.indicatorColor = color;
        return self;
    };
}

- (TGSegmentConfig *(^)(CGFloat ))indicateH{
    return ^(CGFloat height){
        self.indicatorH = height;
        return self;
    };
}

- (TGSegmentConfig *(^)(CGFloat )) indicateExtraW{
    return ^(CGFloat width){
        self.indicatorExtraW = width;
        return self;
    };
}

- (TGSegmentConfig *(^)(UIFont *))normalFont{
    return ^(UIFont * font){
        self.segNormalFont = font;
        return self;
    };
}

- (TGSegmentConfig *(^)(UIFont *))selectedFont{
    return ^(UIFont * font){
        self.segSelectedFont = font;
        return self;
    };
}

- (TGSegmentConfig *(^)(CGFloat ))margin{
    return ^(CGFloat margin){
        self.limitMargin = margin;
        return self;
    };
}

- (TGSegmentConfig *(^)(CGFloat ))moreVCRowCount{
    return ^(CGFloat count){
        self.showMoreVCRowCount = count;
        return self;
    };
}

- (TGSegmentConfig *(^)(CGFloat ))moreCellMinH{
    return ^(CGFloat height){
        self.showMoreCellMinH = height;
        return self;
    };
}

- (TGSegmentConfig *(^)(UIColor *color))moreBtnBorderColor{
    return ^(UIColor *color){
        self.showMoreBtnBorderColor = color;
        return self;
    };
}

- (TGSegmentConfig *(^)(CGFloat width)) moreBtnborderW{
    return ^(CGFloat width){
        self.showMoreBtnborderW = width;
        return self;
    };
}

- (TGSegmentConfig *(^)(UIColor *color))moreBtnTitleColor{
    return ^(UIColor *color){
        self.showMoreBtnTitleColor = color;
        return self;
    };
}

- (TGSegmentConfig *(^)(UIColor *color))moreBtnBGColor{
    return ^(UIColor *color){
        self.showMoreBtnBGColor = color;
        return self;
    };
}

- (TGSegmentConfig *(^)(UIFont *font))moreBtnTitleFont{
    return ^(UIFont * font){
        self.showMoreBtnTitleFont = font;
        return self;
    };
}

- (TGSegmentConfig *(^)(BOOL isShow))showMoreBtnlineView{
    return ^(BOOL isShow){
        self.isShowMoreBtnlineView = isShow;
        return self;
    };
}

- (TGSegmentConfig *(^)(CGFloat height))moreBtnlineViewH{
    return ^(CGFloat height){
        self.showMoreBtnlineViewH = height;
        return self;
    };
}

- (TGSegmentConfig *(^)(UIColor *color))moreBtnlineViewColor{
    return ^(UIColor *color){
        self.showMoreBtnlineViewColor = color;
        return self;
    };
}

- (TGSegmentConfig *(^)(UIColor *color))moreBGColor{
    return ^(UIColor *color){
        self.showMoreBGColor = color;
        return self;
    };
}

- (TGSegmentConfig *(^)(UIColor *color))moreCellBGColor{
    return ^(UIColor *color){
        self.showMoreCellBGColor = color;
        return self;
    };
}

- (TGSegmentConfig *(^)(UIColor *color))coverColor{
    return ^(UIColor *color){
        self.coverViewColor = color;
        return self;
    };
}

- (TGSegmentConfig *(^)(UIColor *color))moreCellTextColor{
    return ^(UIColor *color){
        self.showMoreCellTextColor = color;
        return self;
    };
}

- (TGSegmentConfig *(^)(UIFont *font))moreCellFont{
    return ^(UIFont * font){
        self.showMoreCellFont = font;
        return self;
    };
}

@end
