//
//  TGEssenceVC.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/5.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGEssenceVC.h"
#import "TGTitleBtn.h"
#import "TGVoiceVC.h"
#import "TGAllVC.h"
#import "TGVideoVC.h"
#import "TGPicVC.h"
#import "TGWordVC.h"

@interface TGEssenceVC ()<UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView *scrollV;
@property (nonatomic, strong) UIView *titlesV;
@property (nonatomic, weak) UIView *titleUnderline;
@property (nonatomic, weak) TGTitleBtn *previousClickedTitleBtn;
@end

@implementation TGEssenceVC

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;//UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAllChildVcs];
    [self setupNavBar];
    [self setupScrollView];
    [self.view addSubview:self.titlesV];
    [self addChildVcViewIntoScrollView:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideNav) name:NavigationBarHiddenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNav) name:NavigationBarShowNotification object:nil];
}

-(void) hideNav{
    if (self.titlesV.superview != self.view) return;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    self.titlesV.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = self.titlesV;
    TGFunc
}

-(void) showNav{
    if (self.titlesV.superview == self.view) return;
    [self setupNavBar];
    self.titlesV.backgroundColor = NavTinColor;
    self.titlesV.frame = CGRectMake(0, NavMaxY, self.view.width, TitleVH);
    [self.view addSubview:self.titlesV];
    TGFunc
}

- (void)setupAllChildVcs{
    [self addChildViewController:[[TGAllVC alloc] init]];
    [self addChildViewController:[[TGVideoVC alloc] init]];
    [self addChildViewController:[[TGVoiceVC alloc] init]];
    [self addChildViewController:[[TGPicVC alloc] init]];
    [self addChildViewController:[[TGWordVC alloc] init]];
}

- (void)setupNavBar{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"nav_item_game_icon-1" highImageName:@"nav_item_game_click_icon-1" target:self action:@selector(test)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImageName:@"RandomAcross" highImageName:@"RandomAcrossClick" target:self action:@selector(back)];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MainTitle"]];
}

- (void)setupScrollView{
    // 不允许自动修改UIScrollView的内边距
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
//    scrollView.backgroundColor = [UIColor blueColor];
    scrollView.frame = self.view.bounds;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    //MARK:6个scrollView，设置其中一个为YES才能滚动，多于一个则不会滚动
    scrollView.scrollsToTop = NO; // 点击状态栏的时候，这个scrollView不会滚动到最顶部
    [self.view addSubview:scrollView];
    _scrollV = scrollView;
    
    scrollView.contentSize = CGSizeMake(self.childViewControllers.count * scrollView.width, 0);
}

-(UIView *)titlesV{
    if (!_titlesV){
        UIView *titlesView = [[UIView alloc] init];
        titlesView.backgroundColor = NavTinColor;
        titlesView.frame = CGRectMake(0, NavMaxY, self.view.width, TitleVH);
        _titlesV = titlesView;
        [self setupTitleButtons];
        [self setupTitleUnderline];
    }
    return _titlesV;
}

- (void)setupTitleButtons{
    NSArray *titles = @[ @"全部", @"视频",@"声音", @"图片", @"段子"];
    NSUInteger count = titles.count;
    CGFloat titleBtnW = self.titlesV.width / count;
    CGFloat titleBtnH = self.titlesV.height;
    for (NSUInteger i = 0; i < count; i++) {
        TGTitleBtn *titleBtn = [[TGTitleBtn alloc] init];
        titleBtn.tag = i;
        [titleBtn addTarget:self action:@selector(titleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.titlesV addSubview:titleBtn];
        titleBtn.frame = CGRectMake(i * titleBtnW, 0, titleBtnW, titleBtnH);
        [titleBtn setTitle:titles[i] forState:UIControlStateNormal];
        titleBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    }
}

- (void)setupTitleUnderline{
    TGTitleBtn *firstTitleBtn = self.titlesV.subviews.firstObject;
    UIView *titleUnderline = [[UIView alloc] init];
    titleUnderline.height = 2;
    titleUnderline.y = self.titlesV.height - titleUnderline.height - 1;
    titleUnderline.backgroundColor = [firstTitleBtn titleColorForState:UIControlStateSelected];
    [self.titlesV addSubview:titleUnderline];
    _titleUnderline = titleUnderline;
    
    firstTitleBtn.selected = YES;
    self.previousClickedTitleBtn = firstTitleBtn;
    [firstTitleBtn.titleLabel sizeToFit];//因为处于viewdidload才需要
    self.titleUnderline.width = firstTitleBtn.titleLabel.width + Margin*2;
    self.titleUnderline.centerX = firstTitleBtn.centerX;
}

-(void) titleBtnClick:(TGTitleBtn *) titleBtn {
    if (self.previousClickedTitleBtn == titleBtn) {//重复点击用于刷新
        [[NSNotificationCenter defaultCenter] postNotificationName:TitleButtonDidRepeatClickNotification object:nil];
    }
    [self dealTitleButtonClick:titleBtn];
}

- (void)dealTitleButtonClick:(TGTitleBtn *)titleBtn{
    self.previousClickedTitleBtn.selected = NO;
    titleBtn.selected = YES;
    self.previousClickedTitleBtn = titleBtn;
    
    NSUInteger index = titleBtn.tag;
    [UIView animateWithDuration:0.25 animations:^{
        self.titleUnderline.width = titleBtn.titleLabel.width + Margin * 2;
        self.titleUnderline.centerX = titleBtn.centerX;
        self.scrollV.contentOffset = CGPointMake(self.scrollV.width * index, self.scrollV.contentOffset.y);//MARK: 联动1
    } completion:^(BOOL finished) {
        [self addChildVcViewIntoScrollView:index];
    }];
    
    for (NSUInteger i = 0; i < self.childViewControllers.count; i++) {
        UIViewController *childVc = self.childViewControllers[i];
        if (!childVc.isViewLoaded) continue;//因为view是懒加载，所以不能用view，而要用VC。如果view没有被创建则不处理
        UIScrollView *scrollView = (UIScrollView *)childVc.view;
        if (![scrollView isKindOfClass:[UIScrollView class]]) continue;
        scrollView.scrollsToTop = (i == index);//MARK:6个scrollView，设置其中一个为YES才能滚动，多于一个则不会滚动（方式一，双击顶部状态栏，让显示在当前屏幕上的uiscrollview滚动到头部）
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSUInteger index = scrollView.contentOffset.x / scrollView.width;
    TGTitleBtn *titleBtn = self.titlesV.subviews[index];//[self.titlesV viewWithTag:index]这个会recursive search（includes self），索引为0时会出错,因为返回的是self.titlesV
    [self dealTitleButtonClick:titleBtn];//MARK: 联动2
}

- (void)addChildVcViewIntoScrollView:(NSUInteger)index{
    UIViewController *childVc = self.childViewControllers[index];
    if (childVc.isViewLoaded) return;//这句可以不加，加这句目的是为了不要重复计算childVcView.frame ;[self.scrollV addSubview:childVcView];这句不会重复加入childVcView，因为VC是没有变，VC的view也就是同一个. 也可以使用下面的两种方法
    /*
    UIView *childVcV = self.childViewControllers[index].view;
    if (childVcV.superview) return;
    if (childVcV.window) return;
    */
    
    UIView *childVcView = childVc.view;
    CGFloat scrollViewW = self.scrollV.width;
    //self.automaticallyAdjustsScrollViewInsets = NO;// 虽然设置了此句，但是UITableViewController的view(tableView)仍然距离屏幕上下（顶底）各有20个距离，所以要设置y为0，高度以为self.scrollV.height
    //y为0，高度以为self.scrollV.height，占据整个屏幕目的也是为了全屏cell穿透，即cell的活动范围为全屏，而不是屏幕部分活动（头尾被截）
    //注意 全屏cell活动体验还需要设置tableview的self.tableView.contentInset的[上]左[下]右，代码示例如下
    //self.tableView.contentInset = UIEdgeInsetsMake(NavMaxY + TitleVH, 0, TabBarH, 0);
    childVcView.frame = CGRectMake(index * scrollViewW, 0, scrollViewW, self.scrollV.height);//等于_scrollV.bounds;
    [self.scrollV addSubview:childVcView];
    if (self.titlesV.superview == self.view){
        [[NSNotificationCenter defaultCenter] postNotificationName:NavigationBarShowNotification object:nil userInfo:nil];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:NavigationBarHiddenNotification object:nil userInfo:nil];
    }
}

- (void)test{
    TGFunc
}

- (void)back{
    TGFunc
    [[NSNotificationCenter defaultCenter] postNotificationName:BackEssenceNotification object:nil userInfo:nil];
}

- (void) dealloc{
    TGFunc
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NavigationBarHiddenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NavigationBarShowNotification object:nil];
}

@end
