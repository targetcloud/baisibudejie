//
//  TGFriendTrendVC.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/5.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGFriendTrendVC.h"
#import "TGLoginRegisterVC.h"
#import "TGRecommendVC.h"

@interface TGFriendTrendVC ()

@end

@implementation TGFriendTrendVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavBar];
}

- (void)setupNavBar{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithimage:[UIImage imageNamed:@"friendsRecommentIcon"] highImage:[UIImage imageNamed:@"friendsRecommentIcon-click"] target:self action:@selector(friendsRecomment)];
    self.navigationItem.title = @"我的关注";
    
}

- (void)friendsRecomment{
    TGFunc
    TGRecommendVC * recommendVC = [[TGRecommendVC alloc] init];
    [self.navigationController pushViewController:recommendVC animated:YES];
}

- (IBAction)loginRegister:(id)sender {
    [self presentViewController:[[TGLoginRegisterVC alloc] init] animated:YES completion:nil];
}

@end
