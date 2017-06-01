//
//  TGSementBarVC.m
//  TGSegment
//
//  Created by targetcloud on 2017/4/19.
//  Copyright © 2017年 targetcloud. All rights reserved.
//  Blog http://blog.csdn.net/callzjy
//  Mail targetcloud@163.com
//  Github https://github.com/targetcloud

#import "TGSementBarVC.h"
#import "UIView+TGSegment.h"

@interface TGSementBarVC ()<TGSegmentBarDelegate, UIScrollViewDelegate>//代理的使用 1
@property (nonatomic, weak) UIScrollView *contentV;
@end

@implementation TGSementBarVC

#pragma mark - 以下为懒加载
- (TGSegmentBar *)segmentBar {
    if (!_segmentBar) {
        TGSegmentBar *segmentBar = [TGSegmentBar segmentBarWithFrame:CGRectZero config:nil parentView:self.view];
        segmentBar.delegate = self;//代理的使用 2
        [self.view addSubview:segmentBar];
        _segmentBar = segmentBar;
    }
    return _segmentBar;
}

- (UIScrollView *)contentV {
    if (!_contentV) {
        UIScrollView *contentView = [[UIScrollView alloc] init];
        contentView.delegate = self;
        contentView.pagingEnabled = YES;
        contentView.scrollsToTop = NO;
        contentView.showsVerticalScrollIndicator = NO;
        contentView.showsHorizontalScrollIndicator = NO;
        contentView.tag = 9999;
        [self.view addSubview:contentView];
        _contentV = contentView;
    }
    return _contentV;
}

#pragma mark - .h暴路的方法实现
- (void)setupWithItems: (NSArray <NSString *>*)items childVCs: (NSArray <UIViewController *>*)childVCs {
    NSAssert(items.count != 0 || items.count == childVCs.count, @"标题个数与控制器个数不一致");//条件写正确，条件不成立时执行断言
    self.segmentBar.segmentModels = items;
    [self.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    for (UIViewController *vc in childVCs) {
        [self addChildViewController:vc];//保存在子控制中（而不是数组中）以便在链中的vc可以拿到self.navigationController push...
    }
    self.contentV.contentSize = CGSizeMake(items.count * self.view.width, 0);
    self.segmentBar.selectedIndex = _defaultSelectedIndex;//去掉此句默认是0,在segmentModels设置时会默认点第一个
}

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;//导航等控制下不需要自动调整视图insets
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (self.segmentBar.superview == self.view) {
        self.segmentBar.frame = CGRectMake(0, 64, self.view.width, 35);//如果父视图是自己，那么不要全屏，需要减去segmentBar的高度及64
        CGFloat contentViewY = self.segmentBar.y + self.segmentBar.height;
        //NSLog(@"没有在navigationItem.titleView->%f",self.view.height);
        CGRect contentFrame = CGRectMake(0, contentViewY, self.view.width, self.view.height - contentViewY);
        self.contentV.frame = contentFrame;
        self.contentV.contentSize = CGSizeMake(self.childViewControllers.count * self.view.width, 0);//不需要横竖屏切换可以去掉此句
        //self.segmentBar.selectedIndex = self.segmentBar.selectedIndex;
        return;
    }
    
    CGRect contentFrame = CGRectMake(0, 0,self.view.width,self.view.height);//如果父视图是navigationItem.titleView，那么全屏状态
    self.contentV.frame = contentFrame;
    //NSLog(@"在navigationItem.titleView-->%f",self.view.height);
    self.contentV.contentSize = CGSizeMake(self.childViewControllers.count * self.view.width, 0);//不需要横竖屏切换可以去掉此句
    //self.segmentBar.selectedIndex = self.segmentBar.selectedIndex;
}

#pragma mark - 代理的使用3
- (void)segmentBar:(TGSegmentBar *)segmentBar didSelectIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex{
    //NSLog(@"%zd->%zd", fromIndex, toIndex);
    [self showChildVCViewsAtIndex:toIndex];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = self.contentV.contentOffset.x / self.contentV.width;
    //[self showChildVCViewsAtIndex:index];
    self.segmentBar.selectedIndex = index;
}

#pragma mark - 辅助方法
- (void)showChildVCViewsAtIndex: (NSInteger)index {
    if (self.childViewControllers.count == 0 || index < 0 || index > self.childViewControllers.count - 1) {
        return;
    }
    UIViewController *vc = self.childViewControllers[index];
    //if (vc.isViewLoaded) return;
    vc.view.frame = CGRectMake(index * self.contentV.width, 0, self.contentV.width, self.contentV.height);
    [self.contentV addSubview:vc.view];
    [self.contentV setContentOffset:CGPointMake(index * self.contentV.width, 0) animated:NO];
}

@end
