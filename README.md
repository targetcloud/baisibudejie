# baisibudejie
百思不得姐4.5.6版本高仿

你觉得赞，请Star

### 运行效果

![](https://github.com/targetcloud/baisibudejie/blob/master/1.gif) 

![](https://github.com/targetcloud/baisibudejie/blob/master/2.gif) 

本DEMO高仿最新版百思不得姐（4.5.6），运用了以下第三方框架
DACircularProgress
FLAnimatedImage
pop
...

另外自己定义了一个导航条控件TGSegment，自己的导航条segment与UINavigationController的导航条相互融合，效果见GIF图，这是很多流行的APP使用的功能，当向上滚动视图时，自己的导航条与UINavigationController的bar整合在一起， 同时融合的导航条（高度在64）变得透明，这也是很多流行APP使用的全屏穿透并有透视效果，如果向下滚动视图时，并达到一定速度，那么segment又从UINavigationController的导航条中分离出来，此时的导航条效果是变高了，高出的部分即segment的高度（两者的相加的高度为：64+segment高度）。

除了上面融合分离透视效果外，作者还加入了在segment的导航条最后的更多功能，点击更多按钮，即会弹出一个控制器，让你选择需要跳转的控制器，这也是很多流行APP使用的功能，如网易新闻等。

本DEMO的数据都用Charles抓取，可能后面的版本的请求数据路径地址在将来会有变化，读者可以自行修改，或者告诉作者修改。

在DEMO中，视频、声音、GIF播放均已实现，视频播放不弹出新的控制器进行播放，而是直接在cell上进行播放，GIF及图片缓存是使用自己的缓存实现的，另外评论界面中的语音播放功能也已经加入。

本DEMO中，也已经实现历史穿越功能，点击精华导航条右上角按钮即可穿越到旧版本，即呈现（全部 视频 声音 图片 段子）这5个控制器的界面。

使用TGSegment的代码如下（若要显示更多按钮功能，那么//.showMore(YES)去掉这句注释即可，本示例使用的链式编程语法）
```objc
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
        [self addChildViewController:vc];
        _segmentBarVC = vc;
    }
    return _segmentBarVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.segmentBarVC.segmentBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 35);
    self.segmentBarVC.view.frame = self.view.bounds;
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
              .selectedFont([UIFont systemFontOfSize:14])
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
}
@end
```
##### 截图
1
<img src="https://github.com/targetcloud/baisibudejie/blob/master/IMG_2014.PNG" width = "60%" />
2
<img src="https://github.com/targetcloud/baisibudejie/blob/master/IMG_1978.PNG" width = "60%" />
3
<img src="https://github.com/targetcloud/baisibudejie/blob/master/IMG_2016.PNG" width = "60%" />
4
<img src="https://github.com/targetcloud/baisibudejie/blob/master/IMG_2017.PNG" width = "60%" />
5
<img src="https://github.com/targetcloud/baisibudejie/blob/master/IMG_2018.PNG" width = "60%" />
6
<img src="https://github.com/targetcloud/baisibudejie/blob/master/IMG_2019.PNG" width = "60%" />
7
<img src="https://github.com/targetcloud/baisibudejie/blob/master/IMG_2020.PNG" width = "60%" />
8
<img src="https://github.com/targetcloud/baisibudejie/blob/master/IMG_2022.PNG" width = "60%" />
9
<img src="https://github.com/targetcloud/baisibudejie/blob/master/IMG_2023.PNG" width = "60%" />
10
<img src="https://github.com/targetcloud/baisibudejie/blob/master/IMG_2028.PNG" width = "60%" />

### 如果您喜欢本项目,请Star 

欢迎关注我的[博客](http://blog.csdn.net/callzjy)
