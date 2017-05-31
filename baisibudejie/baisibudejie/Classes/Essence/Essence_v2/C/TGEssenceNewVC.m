//
//  TGEssenceNewVC.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/29.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGEssenceNewVC.h"
#import "TGSementBarVC.h"
#import "TGTopicNewVC.h"
#import "TGRecommendedVC.h"
#import "TGVideoPlayVC.h"
#import "TGPictureVC.h"
#import "TGJokesVC.h"
#import "TGRankingVC.h"
#import "TGInteractVC.h"
#import "TGRedNetVC.h"
#import "TGSocietyVC.h"
#import "TGVoteVC.h"
#import "TGBeautyVC.h"
#import "TGColdKnowledgeVC.h"
#import "TGGameVC.h"

@interface TGEssenceNewVC ()
@property (nonatomic, weak) TGSementBarVC *segmentBarVC;
@end

@implementation TGEssenceNewVC

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
    NSArray *items = @[@"推荐", @"视频", @"图片", @"段子",@"排行",@"互动区",@"网红",@"社会",@"投票",@"美女",@"冷知识",@"游戏"];
    NSMutableArray* childVCs = [NSMutableArray array];
    [childVCs addObject:[[TGRecommendedVC alloc] init]];
    [childVCs addObject:[[TGVideoPlayVC alloc] init]];
    [childVCs addObject:[[TGPictureVC alloc] init]];
    [childVCs addObject:[[TGJokesVC alloc] init]];
    [childVCs addObject:[[TGRankingVC alloc] init]];
    [childVCs addObject:[[TGInteractVC alloc] init]];
    [childVCs addObject:[[TGRedNetVC alloc] init]];
    [childVCs addObject:[[TGSocietyVC alloc] init]];
    [childVCs addObject:[[TGVoteVC alloc] init]];
    [childVCs addObject:[[TGBeautyVC alloc] init]];
    [childVCs addObject:[[TGColdKnowledgeVC alloc] init]];
    [childVCs addObject:[[TGGameVC alloc] init]];
    [self.segmentBarVC setupWithItems:items childVCs:childVCs];

    [self.segmentBarVC.segmentBar updateViewWithConfig:^(TGSegmentConfig *config) {
        config.selectedColor([UIColor lightTextColor])
              .normalColor([UIColor lightTextColor])
              .selectedFont([UIFont systemFontOfSize:14])//选中字体大于其他正常标签的字体的情况下，根据情况稍微调大margin（默认8），以免选中的字体变大后挡住其他正常标签的内容
              .normalFont([UIFont systemFontOfSize:13])
              .indicateExtraW(8)
              .indicateH(2)
              .indicateColor([UIColor whiteColor])
              //.showMore(YES)
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
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageName:@"nav_item_game_icon-1" highImageName:@"nav_item_game_click_icon-1" target:self action:@selector(test)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImageName:@"RandomAcross" highImageName:@"RandomAcrossClick" target:self action:@selector(randomAcross)];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MainTitle"]];
}

- (void)test{
    TGFunc
}

-(void)randomAcross{
    TGFunc
    [[NSNotificationCenter defaultCenter] postNotificationName:AcrossEssenceNotification object:nil userInfo:nil];
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
