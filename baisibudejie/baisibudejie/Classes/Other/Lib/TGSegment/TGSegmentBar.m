//
//  TGSegmentBar.m
//  TGSegment
//
//  Created by targetcloud on 2017/4/18.
//  Copyright © 2017年 targetcloud. All rights reserved.
//  Blog http://blog.csdn.net/callzjy
//  Mail targetcloud@163.com
//  Github https://github.com/targetcloud

#import "TGSegmentBar.h"
#import "TGShowMoreVC.h"
#import "TGSegmentMoreBtn.h"
#import "UIView+TGSegment.h"

#define kShowMoreBtnW (self.bounds.size.height + 30)

@interface TGSegmentBar()<UICollectionViewDelegate>
{
    TGSegmentConfig * _segmentConfig;
}
@property (nonatomic, strong) UIScrollView *contentScrollV;
@property (nonatomic, strong) UIView *indicatorV;
@property (nonatomic, strong) TGSegmentMoreBtn *showMoreBtn;
@property (nonatomic, strong) NSMutableArray <UIButton *>*segBtns;
@property (nonatomic, weak) UIButton *lastBtn;
//@property (nonatomic, strong) TGSegmentConfig *segmentConfig;
@property (nonatomic, strong) UIView *coverV;
@property (nonatomic, strong) TGShowMoreVC *showMoreVC;
@end

@implementation TGSegmentBar

#pragma mark - 以下为懒加载

- (TGSegmentConfig *) segmentConfig{
    if (!_segmentConfig){
        _segmentConfig = [TGSegmentConfig defaultConfig];
    }
    return _segmentConfig;
}

- (TGShowMoreVC *)showMoreVC {
    if (!_showMoreVC) {
        _showMoreVC = [[TGShowMoreVC alloc] initWithConfig:self.segmentConfig];
        _showMoreVC.collectionView.delegate = self;
    }
    //若有父视图，则在父视图，没有的话，则在self.superview
    CGFloat maxY = CGRectGetMaxY(self.frame);
    CGFloat statusH = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat navH = self.viewController.navigationController.navigationBar.frame.size.height;
    navH += (navH > 0) ? statusH : 0;
    maxY += (maxY <= 35) ? navH : 0;
    
    //NSLog(@"%@,%f,%f,%f,%f",self.superview,self.y , self.height,self.y + self.height,maxY);//4.666667,35.000000,39.666667,39.666667 或 64.000000,35.000000,99.000000,99.000000
    
    _showMoreVC.collectionView.frame = CGRectMake(0,
                        ([self.superview isKindOfClass:UINavigationBar.class] ? CGRectGetMaxY(self.superview.frame) : maxY) ,
                                                      [UIScreen mainScreen].bounds.size.width,
                                                      0);
    _showMoreVC.collectionView.backgroundColor = self.segmentConfig.showMoreBGColor;
    if (_showMoreVC.collectionView.superview != (_parentV ? _parentV : self.superview)) {
        [(_parentV ? _parentV : self.superview) addSubview:_showMoreVC.collectionView];
    }
    return _showMoreVC;
}

- (UIView *)coverV {
    if (!_coverV) {
        _coverV = [[UIView alloc] init];
        UITapGestureRecognizer *gester = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePanel)];
        [_coverV addGestureRecognizer:gester];
    }
    CGFloat maxY = CGRectGetMaxY(self.frame);
    CGFloat statusH = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat navH = self.viewController.navigationController.navigationBar.frame.size.height;
    navH += (navH > 0) ? statusH : 0;
    maxY += (maxY <= 35) ? navH : 0;
    
    _coverV.frame=CGRectMake(0,
                            ([self.superview isKindOfClass:UINavigationBar.class] ? CGRectGetMaxY(self.superview.frame) : maxY) ,
                            [UIScreen mainScreen].bounds.size.width,
                            0);
    _coverV.backgroundColor = self.segmentConfig.coverViewColor;
    if (!_coverV.superview) {
        //同上 若有父视图，则在父视图，没有的话，则在self.superview
        [(_parentV ? _parentV : self.superview) insertSubview:_coverV belowSubview:self.showMoreVC.collectionView];
    }
    return _coverV;
}

- (TGSegmentMoreBtn *)showMoreBtn{
    if (!_showMoreBtn) {
//        NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
//        NSString *sourcePath = [currentBundle.infoDictionary[@"CFBundleName"] stringByAppendingString:@".bundle"];
//        NSString *showImgPath = [currentBundle pathForResource:@"icon_radio_show@2x" ofType:@".png" inDirectory:sourcePath];
//        UIImage *showImage = [UIImage imageWithContentsOfFile:showImgPath];
//        NSString *hideImgPath = [currentBundle pathForResource:@"icon_radio_hide@2x" ofType:@".png" inDirectory:sourcePath];
//        UIImage *hideImage = [UIImage imageWithContentsOfFile:hideImgPath];
        
        UIImage * showImage = [UIImage imageNamed:@"threeColumn_open_icon"];//threeColumn_open_icon//Profile_filter_downClick
        UIImage * hideImage = [UIImage imageNamed:@"threeColumn_close_icon"];//Profile_filter_upClick
        
        _showMoreBtn = [[TGSegmentMoreBtn alloc] init];
        [_showMoreBtn setTitle:@"更多" forState:UIControlStateNormal];
        [_showMoreBtn setImage:showImage forState:UIControlStateNormal];
        _showMoreBtn.layer.borderColor = [self.segmentConfig.showMoreBtnBorderColor CGColor];
        _showMoreBtn.layer.borderWidth = self.segmentConfig.showMoreBtnborderW;
        _showMoreBtn.layer.masksToBounds = YES;
        _showMoreBtn.layer.cornerRadius = self.segmentConfig.indicatorH * 2;
        [_showMoreBtn setTitle:@"收起" forState:UIControlStateSelected];
        [_showMoreBtn setImage:hideImage forState:UIControlStateSelected];
        _showMoreBtn.imageView.contentMode = UIViewContentModeCenter;
        [_showMoreBtn setTitleColor:self.segmentConfig.showMoreBtnTitleColor forState:UIControlStateNormal];
        _showMoreBtn.backgroundColor = self.segmentConfig.showMoreBtnBGColor;
        _showMoreBtn.titleLabel.font = self.segmentConfig.showMoreBtnTitleFont;
        
        UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(self.segmentConfig.limitMargin * 0.5, (self.segmentConfig.segmentBarH - self.segmentConfig.showMoreBtnlineViewH) * 0.5 - self.segmentConfig.indicatorH * 2 + 2, 1, self.segmentConfig.showMoreBtnlineViewH -2)];
        lineV.backgroundColor = self.segmentConfig.showMoreBtnlineViewColor;
        if (self.segmentConfig.isShowMoreBtnlineView){
            [_showMoreBtn addSubview:lineV];
        }
        
        [_showMoreBtn addTarget:self action:@selector(showOrHide:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_showMoreBtn];
    }
    return _showMoreBtn;
}

- (UIScrollView *)contentScrollV {
    if (!_contentScrollV) {
        _contentScrollV = [[UIScrollView alloc] init];
        _contentScrollV.showsHorizontalScrollIndicator = NO;
        _contentScrollV.showsVerticalScrollIndicator = NO;
        
        [self addSubview:_contentScrollV];
    }
    return _contentScrollV;
}

- (UIView *)indicatorV {
    if (!_indicatorV) {
        _indicatorV = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - self.segmentConfig.indicatorH -1, 0, self.segmentConfig.indicatorH)];
        _indicatorV.backgroundColor = self.segmentConfig.indicatorColor;
        [self.contentScrollV addSubview:_indicatorV];
    }
    return _indicatorV;
}

- (NSMutableArray<UIButton *> *)segBtns{
    if (!_segBtns) {
        _segBtns = [NSMutableArray array];
    }
    return _segBtns;
}

#pragma mark - 以下为重写.h暴露的属性的set方法
-(void)setSegmentConfig:(TGSegmentConfig *)segmentConfig{
    _segmentConfig = segmentConfig;
    self.height = segmentConfig.segmentBarH;
    self.backgroundColor = segmentConfig.segmentBarBGColor;
    self.indicatorV.backgroundColor= segmentConfig.indicatorColor;
    self.indicatorV.height = segmentConfig.indicatorH;
    [self.showMoreBtn removeFromSuperview];
    self.showMoreBtn = nil;
    [self.showMoreVC.collectionView removeFromSuperview];
    self.showMoreVC = nil;
    [self.coverV removeFromSuperview];
    self.coverV = nil;
    for (UIButton *btn in self.segBtns) {
        [btn setTitleColor:segmentConfig.segNormalColor forState:UIControlStateNormal];
        [btn setTitleColor:segmentConfig.segSelectedColor forState:UIControlStateSelected];
        if (btn != self.lastBtn) {
            btn.titleLabel.font = segmentConfig.segNormalFont;
        }else {
            btn.titleLabel.font = segmentConfig.segSelectedFont;
        }
    }
    if (self.segmentConfig.isShowMore) {
        self.showMoreVC.items = _segmentModels;
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
    //[self layoutSubviews];
}

-(void)setSegmentModels:(NSArray<NSString *> *)segmentModels{
    _segmentModels = segmentModels;
    
    if (self.segmentConfig.isShowMore) {
        self.showMoreVC.items = _segmentModels;
        //self.showMoreVC.collectionView.height = 0;
    }
    
    [self.segBtns makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.segBtns = nil;
    self.lastBtn = nil;
    
    for (NSString* segM in segmentModels) {
        UIButton *btn = [[UIButton alloc] init];
        btn.tag = self.segBtns.count;
        
        [btn addTarget:self action:@selector(segmentClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = self.segmentConfig.segNormalFont;
        [btn setTitleColor:self.segmentConfig.segNormalColor forState:UIControlStateNormal];
        [btn setTitleColor:self.segmentConfig.segSelectedColor forState:UIControlStateSelected];//Selected 代码控制 ，不是用户触发
        [btn setTitle:segM forState:UIControlStateNormal];
        [btn sizeToFit];
        [self.contentScrollV addSubview:btn];
        [self.segBtns addObject:btn];
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
    //[self layoutSubviews];
    if (self.segBtns.count > 0){
        [self segmentClick:[self.segBtns firstObject]];
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (self.segBtns.count == 0 || selectedIndex < 0 || selectedIndex > self.segBtns.count - 1) {
        return;
    }
    _selectedIndex = selectedIndex;
    [self segmentClick:self.segBtns[selectedIndex]];
}

#pragma mark - 以下为.h暴露的方法
+ (instancetype)segmentBarWithFrame: (CGRect)frame config: (TGSegmentConfig *)config parentView: (UIView *)parentV {
    CGFloat segmentBarH = config ? config.segmentBarH : frame.size.height;

    CGRect defaultFrame;
    if (CGRectIsNull(frame) || CGRectIsEmpty(frame)) {
        defaultFrame= CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, segmentBarH);
    }else{
        defaultFrame=frame;
        defaultFrame.size.height = segmentBarH;
    }
    
    TGSegmentBar *segBar = [[TGSegmentBar alloc] initWithFrame:defaultFrame];
    if (config){
        segBar.segmentConfig = config;
    }
    segBar.parentV = parentV;
    return segBar;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //self.segmentConfig = [TGSegmentConfig defaultConfig];//移至懒加载
        self.backgroundColor = self.segmentConfig.segmentBarBGColor;
    }
    return self;
}

- (void)updateViewWithConfig: (void(^)(TGSegmentConfig *config))configBlock{
    if (configBlock) {
        configBlock(self.segmentConfig);
    }
    [self hidePanel];
    self.segmentConfig = self.segmentConfig;
}

#pragma mark - 事件处理
- (void)segmentClick: (UIButton *)btn {
    _selectedIndex = btn.tag;//用下划线，不能用self.selectedIndex = btn.tag;self.会调用set方法          作用是记录selectedIndex，供.h头文件外面get
    if ([self.delegate respondsToSelector:@selector(segmentBar:didSelectIndex:fromIndex:)]){
        [self.delegate segmentBar: self didSelectIndex:_selectedIndex fromIndex:self.lastBtn.tag];//代理的定义 3
    }
    
    self.lastBtn.selected = NO;
    self.lastBtn.titleLabel.font = self.segmentConfig.segNormalFont;
    [self.lastBtn sizeToFit];
    self.lastBtn.height = self.contentScrollV.height - self.segmentConfig.indicatorH;
    btn.selected = YES;
    btn.titleLabel.font = self.segmentConfig.segSelectedFont;
    [btn sizeToFit];
    btn.height = self.contentScrollV.height - self.segmentConfig.indicatorH;
    self.lastBtn = btn;
    
    if (self.segmentConfig.isShowMore) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.lastBtn.tag inSection:0];
        [self.showMoreVC.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        [self hidePanel];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        NSString *text = btn.titleLabel.text;
        CGSize size = [text sizeWithAttributes:@{NSFontAttributeName : btn.titleLabel.font}];
        self.indicatorV.y = self.contentScrollV.height - self.segmentConfig.indicatorH -1;
        self.indicatorV.width = size.width + self.segmentConfig.indicatorExtraW * 2;
        self.indicatorV.centerX = btn.centerX;
    }];
    
    CGFloat shouldScrollX = btn.centerX - self.contentScrollV.width * 0.5;
    if (shouldScrollX < 0) {
        shouldScrollX = 0;
    }
    if (shouldScrollX > self.contentScrollV.contentSize.width - self.contentScrollV.width) {
        shouldScrollX = self.contentScrollV.contentSize.width - self.contentScrollV.width;
    }
    [self.contentScrollV setContentOffset:CGPointMake(shouldScrollX, 0) animated:YES];
}

- (void)showOrHide: (UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self showPanel];
    }else {
        [self hidePanel];
    }
}

- (void)showPanel {
    self.showMoreBtn.selected = YES;
    self.showMoreVC.collectionView.hidden = NO;
    self.coverV.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.showMoreVC.collectionView.height = self.showMoreVC.collectionView.contentSize.height;
        self.coverV.height = [UIScreen mainScreen].bounds.size.height - (self.y + self.height);
    }];
}

- (void)hidePanel {
    self.showMoreBtn.selected = NO;
    [UIView animateWithDuration:0.2 animations:^{
        //self.showMoreVC.collectionView.height = 0;
        self.coverV.height = 0;
    } completion:^(BOOL finished) {
        self.coverV.hidden = YES;
        self.showMoreVC.collectionView.hidden = YES;
    }];
}

#pragma mark - 布局
-(void)layoutSubviews {
    [super layoutSubviews];

    if (!self.segmentConfig.isShowMore) {
        self.contentScrollV.frame = self.bounds;
        self.showMoreBtn.width = -1;
    }else {
        self.contentScrollV.frame = CGRectMake(0, 0, self.width - kShowMoreBtnW, self.height);
        self.showMoreBtn.frame = CGRectMake(self.width - kShowMoreBtnW - self.segmentConfig.indicatorH, self.segmentConfig.indicatorH, kShowMoreBtnW, self.height - self.segmentConfig.indicatorH * 4);
    }
    
    CGFloat titleTotalW = 0;
    for (int i = 0; i < self.segBtns.count; i++)  {
        [self.segBtns[i] sizeToFit];
        CGFloat width = self.segBtns[i].width;
        titleTotalW += width;
    }
    
    CGFloat margin = (self.contentScrollV.width - titleTotalW) / (self.segmentModels.count + 1);
    margin = margin < self.segmentConfig.limitMargin ? self.segmentConfig.limitMargin : margin;
    
    CGFloat btnY = 0;
    CGFloat btnH = self.contentScrollV.height - self.segmentConfig.indicatorH;
    UIButton *lastBtn;
    for (int i = 0; i < self.segBtns.count; i++) {
        CGFloat btnX = CGRectGetMaxX(lastBtn.frame) + margin;
        self.segBtns[i].x = btnX;
        self.segBtns[i].y = btnY;
        self.segBtns[i].height = btnH;
        lastBtn = self.segBtns[i];
    }
    self.contentScrollV.contentSize = CGSizeMake(CGRectGetMaxX(lastBtn.frame) + margin, 0);
    
    if (self.segBtns.count == 0) {
        return;
    }
    
    if (self.lastBtn) {
        CGSize size = [self.lastBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName : self.lastBtn.titleLabel.font}];
        self.indicatorV.y = self.contentScrollV.height - self.segmentConfig.indicatorH -1;
        self.indicatorV.width = size.width + self.segmentConfig.indicatorExtraW * 2;
        self.indicatorV.centerX = self.lastBtn.centerX;
    }
}

#pragma mark <UICollectionViewDelegate>代理
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedIndex = indexPath.row;
    [self hidePanel];
}

- (UIViewController *)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

@end
