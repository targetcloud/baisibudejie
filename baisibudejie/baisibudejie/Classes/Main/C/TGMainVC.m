//
//  TGMainVC.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/5.
//  Copyright © 2017年 targetcloud. All rights reserved.
//  Blog http://blog.csdn.net/callzjy
//  Mail targetcloud@163.com
//  Github https://github.com/targetcloud

#import "TGMainVC.h"
#import "TGEssenceVC.h"
#import "TGEssenceNewVC.h"
#import "TGNewestVC.h"
#import "TGFriendTrendVC.h"
#import "TGMeVC.h"
#import "TGNewVC.h"
#import "TGPublishVC.h"
#import "TGTabBar.h"
#import "TGNavigationVC.h"

@interface TGMainVC ()//MARK:1 UITabBarDelegate <UITabBarDelegate> 不用写，TabBarVC已经是TabBar的代理了

@end

@implementation TGMainVC

+ (void)load{
    UITabBarItem *item = [UITabBarItem appearanceWhenContainedIn:self, nil];
    
    NSMutableDictionary *attrsSelected = [NSMutableDictionary dictionary];
    attrsSelected[NSForegroundColorAttributeName] = [UIColor blackColor];
    [item setTitleTextAttributes:attrsSelected forState:UIControlStateSelected];
    
    NSMutableDictionary *attrsNormal = [NSMutableDictionary dictionary];
    attrsNormal[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    [item setTitleTextAttributes:attrsNormal forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAllChildVC];
    [self setupAllTitleButton];
    [self setupTabBar];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(back) name:BackEssenceNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(across) name:AcrossEssenceNotification object:nil];
}

//- (void) viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    
//}

-(void) setupTabBar {
    TGTabBar * tabbar = [[TGTabBar alloc] init];
//    self.tabBar = tabbar;
    [self setValue:tabbar forKeyPath:@"tabBar"];
    [self.tabBar setBackgroundImage:[UIImage imageNamed:@"tabbar-light"]];
    
    //self.tabBar.delegate = self;//MARK:2 UITabBarDelegate  TabBarVC已经是TabBar的代理了
    /*
     2017-03-09 23:26:29.681 baisibudejie[8046:301201] *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Changing the delegate of a tab bar managed by a tab bar controller is not allowed.'
     */
}

- (void) back {
    TGNavigationVC *essenceVc = [[TGNavigationVC alloc] initWithRootViewController:[[TGEssenceNewVC alloc] init]];
    TGNavigationVC *newVc = [[TGNavigationVC alloc] initWithRootViewController:[[TGNewestVC alloc] init]];
    self.viewControllers = @[essenceVc,newVc,self.childViewControllers[2],self.childViewControllers[3]];
    [self setupAllTitleButton];
}

- (void) across{
    TGNavigationVC * acrossVc =[[TGNavigationVC alloc] initWithRootViewController:[[TGEssenceVC alloc] init]];
    TGNavigationVC *newVc = [[TGNavigationVC alloc] initWithRootViewController:[[TGNewVC alloc] init]];
    self.viewControllers = @[acrossVc,newVc,self.childViewControllers[2],self.childViewControllers[3]];
    [self setupAllTitleButton];
}

- (void)setupAllChildVC{
    TGNavigationVC *essenceVc = [[TGNavigationVC alloc] initWithRootViewController:[[TGEssenceNewVC alloc] init]];
    TGNavigationVC *newVc = [[TGNavigationVC alloc] initWithRootViewController:[[TGNewestVC alloc] init]];
    TGNavigationVC *ftVc = [[TGNavigationVC alloc] initWithRootViewController:[[TGFriendTrendVC alloc] init]];
    TGNavigationVC *meVc = [[TGNavigationVC alloc] initWithRootViewController:[[UIStoryboard storyboardWithName:NSStringFromClass([TGMeVC class]) bundle:nil] instantiateInitialViewController]];
    
    self.viewControllers = @[essenceVc,newVc,ftVc,meVc];
    
//    [self addChildViewController:essenceVc];
//    [self addChildViewController:newVc];
//    [self addChildViewController:ftVc];
//    [self addChildViewController:meVc];
    
}

- (void)setupAllTitleButton{
    UINavigationController *nav = self.childViewControllers[0];
    nav.tabBarItem.title = @"精华";
    nav.tabBarItem.image = [UIImage imageNamed:@"tabBar_essence_icon"];
    nav.tabBarItem.selectedImage = [UIImage imageOriginalWithName:@"tabBar_essence_click_icon"];
    
    UINavigationController *nav1 = self.childViewControllers[1];
    nav1.tabBarItem.title = @"新帖";
    nav1.tabBarItem.image = [UIImage imageNamed:@"tabBar_new_icon"];
    nav1.tabBarItem.selectedImage = [UIImage imageOriginalWithName:@"tabBar_new_click_icon"];
    
//    TGPublishVC *publishVc = self.childViewControllers[2];
//    publishVc.tabBarItem.image = [UIImage imageOriginalWithName:@"tabBar_publish_icon"];
//    publishVc.tabBarItem.selectedImage = [UIImage imageOriginalWithName:@"tabBar_publish_click_icon"];
//    publishVc.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
//    
    UINavigationController *nav3 = self.childViewControllers[2];
    nav3.tabBarItem.title = @"关注";
    nav3.tabBarItem.image = [UIImage imageNamed:@"tabBar_friendTrends_icon"];
    nav3.tabBarItem.selectedImage = [UIImage imageOriginalWithName:@"tabBar_friendTrends_click_icon"];
    
    UINavigationController *nav4 = self.childViewControllers[3];
    nav4.tabBarItem.title = @"我";
    nav4.tabBarItem.image = [UIImage imageNamed:@"tabBar_me_icon"];
    nav4.tabBarItem.selectedImage = [UIImage imageOriginalWithName:@"tabBar_me_click_icon"];
}

- (void) dealloc{
    TGFunc
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BackEssenceNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AcrossEssenceNotification object:nil];
}

@end
