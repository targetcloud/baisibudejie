//
//  TGNewestVC.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/31.
//  Copyright © 2017年 targetcloud. All rights reserved.
//  Blog http://blog.csdn.net/callzjy
//  Mail targetcloud@163.com
//  Github https://github.com/targetcloud

#import "TGNewestVC.h"
#import "TGSementBarVC.h"
#import "TGTopicNewVC.h"
#import "TGNewestTotalVC.h"
#import "TGNewestVideoVC.h"
#import "TGNewestPictureVC.h"
#import "TGNewestJokesVC.h"
#import "TGNewestInteractVC.h"
#import "TGNewestAlbumVC.h"
#import "TGNewestRedNetVC.h"
#import "TGNewestVoteVC.h"
#import "TGNewestBeautyVC.h"
#import "TGNewestColdKnowledgeVC.h"
#import "TGNewestGameVC.h"
#import "TGNewestSoundsVC.h"

@interface TGNewestVC ()
@property (nonatomic, weak) TGSementBarVC *segmentBarVC;
@end

@implementation TGNewestVC

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;//UIStatusBarStyleDefault;
}

- (TGSementBarVC *)segmentBarVC {
    if (!_segmentBarVC) {
        TGSementBarVC *vc = [[TGSementBarVC alloc] init];
        [self addChildViewController:vc];//成链
        _segmentBarVC = vc;
    }
    return _segmentBarVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.segmentBarVC.segmentBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 35);
    //设置segmentBarVC大小
    self.segmentBarVC.view.frame = self.view.bounds;
    //使用segmentBarVC
    [self.view addSubview:self.segmentBarVC.view];
    NSArray *items = @[@"全部", @"视频", @"图片", @"段子",@"互动区",@"相册",@"网红",@"投票",@"美女",@"冷知识",@"游戏",@"声音"];
    NSMutableArray* childVCs = [NSMutableArray array];
    [childVCs addObject:[[TGNewestTotalVC alloc] init]];
    [childVCs addObject:[[TGNewestVideoVC alloc] init]];
    [childVCs addObject:[[TGNewestPictureVC alloc] init]];
    [childVCs addObject:[[TGNewestJokesVC alloc] init]];
    [childVCs addObject:[[TGNewestInteractVC alloc] init]];
    [childVCs addObject:[[TGNewestAlbumVC alloc] init]];
    [childVCs addObject:[[TGNewestRedNetVC alloc] init]];
    [childVCs addObject:[[TGNewestVoteVC alloc] init]];
    [childVCs addObject:[[TGNewestBeautyVC alloc] init]];
    [childVCs addObject:[[TGNewestColdKnowledgeVC alloc] init]];
    [childVCs addObject:[[TGNewestGameVC alloc] init]];
    [childVCs addObject:[[TGNewestSoundsVC alloc] init]];
    
    [self.segmentBarVC setupWithItems:items childVCs:childVCs];
    
    [self.segmentBarVC.segmentBar updateViewWithConfig:^(TGSegmentConfig *config) {
        config.selectedColor([UIColor lightTextColor])
        .normalColor([UIColor lightTextColor])
        .selectedFont([UIFont systemFontOfSize:14])//选中字体大于其他正常标签的字体的情况下，根据情况稍微调大margin（默认8），以免选中的字体变大后挡住其他正常标签的内容
        .normalFont([UIFont systemFontOfSize:13])
        .indicateExtraW(8)
        .indicateH(2)
        .indicateColor([UIColor whiteColor])
        .showMore(YES)
        .moreCellBGColor([[UIColor grayColor] colorWithAlphaComponent:0.3])
        .moreBGColor([UIColor clearColor])
        .moreCellFont([UIFont systemFontOfSize:13])
        .moreCellTextColor(NavTinColor)
        .moreCellMinH(30)
        .showMoreBtnlineView(YES)
        .moreBtnlineViewColor([UIColor lightTextColor])
        .moreBtnTitleFont([UIFont systemFontOfSize:13])
        .moreBtnTitleColor([UIColor lightTextColor])
        .margin(18)
        .barBGColor(NavTinColor)
        ;
    }];
    
    [self setupNavBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideNav) name:NavigationBarHiddenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNav) name:NavigationBarShowNotification object:nil];
}

- (void)setupNavBar{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"review_post_nav_icon" highImageName:@"review_post_nav_icon_click" target:self action:@selector(check)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImageName:@"nav_search_icon" highImageName:@"nav_search_icon_click" target:self action:@selector(search)];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MainTitle"]];
}

- (void)check{
    TGFunc
}

- (void)search{
    TGFunc
}

-(void) hideNav{
    if (self.segmentBarVC.segmentBar.superview != self.segmentBarVC.view) return;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    self.segmentBarVC.segmentBar.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = self.segmentBarVC.segmentBar;
    TGFunc
}

-(void) showNav{
    if (self.segmentBarVC.segmentBar.superview == self.segmentBarVC.view) return;
    [self setupNavBar];
    self.segmentBarVC.segmentBar.backgroundColor = NavTinColor;
    self.segmentBarVC.segmentBar.frame = CGRectMake(0, NavMaxY, self.segmentBarVC.view.width, TitleVH);
    [self.segmentBarVC.view addSubview:self.segmentBarVC.segmentBar];
    TGFunc
}

- (void) dealloc{
    TGFunc
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NavigationBarHiddenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NavigationBarShowNotification object:nil];
}

@end
