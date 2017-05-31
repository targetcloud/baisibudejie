//
//  TGEssenceNewVC.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/29.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGEssenceNewVC.h"
#import "TGSementBarVC.h"
#import "TGVoiceVC.h"
#import "TGAllVC.h"
#import "TGVideoVC.h"
#import "TGPicVC.h"
#import "TGWordVC.h"

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
    //self.automaticallyAdjustsScrollViewInsets = NO;
    self.segmentBarVC.segmentBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 35);
    //当titleView时，把左右按钮都不要显示（可选）
    //self.navigationItem.rightBarButtonItem = nil;
    //把segmentBar放navigationItem.titleView（可选）
    //self.navigationItem.titleView = self.segmentBarVC.segmentBar;
    //设置segmentBarVC大小
    self.segmentBarVC.view.frame = self.view.bounds;
    //使用segmentBarVC
    [self.view addSubview:self.segmentBarVC.view];
    NSArray *items = @[@"推荐", @"视频", @"图片", @"段子", @"投票",@"排行",@"互动区",@"网红",@"社会",@"美女",@"冷知识",@"游戏"];
    NSMutableArray* childVCs = [NSMutableArray array];
    [childVCs addObject:[[TGAllVC alloc] init]];
    [childVCs addObject:[[TGVideoVC alloc] init]];
    [childVCs addObject:[[TGVoiceVC alloc] init]];
    [childVCs addObject:[[TGPicVC alloc] init]];
    [childVCs addObject:[[TGWordVC alloc] init]];
    [childVCs addObject:[[TGAllVC alloc] init]];
    [childVCs addObject:[[TGVideoVC alloc] init]];
    [childVCs addObject:[[TGVoiceVC alloc] init]];
    [childVCs addObject:[[TGPicVC alloc] init]];
    [childVCs addObject:[[TGWordVC alloc] init]];
    [childVCs addObject:[[TGPicVC alloc] init]];
    [childVCs addObject:[[TGWordVC alloc] init]];
    [self.segmentBarVC setupWithItems:items childVCs:childVCs];

    [self.segmentBarVC.segmentBar updateViewWithConfig:^(TGSegmentConfig *config) {
        config.selectedColor([UIColor lightTextColor])
              .normalColor([UIColor lightTextColor])
              .selectedFont([UIFont systemFontOfSize:14])//选中字体大于其他正常标签的字体的情况下，根据情况稍微调大margin（默认8），以免选中的字体变大后挡住其他正常标签的内容
              .normalFont([UIFont systemFontOfSize:13])
              .indicateExtraW(1)
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
