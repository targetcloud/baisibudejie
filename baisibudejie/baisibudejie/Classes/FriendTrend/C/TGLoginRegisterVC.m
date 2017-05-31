//
//  TGLoginRegisterVC.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/6.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGLoginRegisterVC.h"
#import "TGLoginRegisterV.h"
#import "TGThirdLoginV.h"

@interface TGLoginRegisterVC ()
@property (weak, nonatomic) IBOutlet UIView *middleV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleVLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@end

@implementation TGLoginRegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    TGLoginRegisterV * loginV = [TGLoginRegisterV loginView];
    TGLoginRegisterV * regV = [TGLoginRegisterV registerView];
    
    [self.middleV addSubview:loginV];
    [self.middleV addSubview:regV];
//    regV.x = self.middleV.width * 0.5;
    
    TGThirdLoginV *fastLoginV = [TGThirdLoginV fastLoginView];
    [self.bottomView addSubview:fastLoginV];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    TGLoginRegisterV *loginV = self.middleV.subviews[0];
    loginV.frame = CGRectMake(0, 0, self.middleV.width * 0.5, self.middleV.height);//XIB最外层要管，内部由约束管
    TGLoginRegisterV *regV = self.middleV.subviews[1];
    regV.frame = CGRectMake( self.middleV.width * 0.5, 0,self.middleV.width * 0.5, self.middleV.height);//XIB最外层要管，内部由约束管
    
    TGThirdLoginV *fastLoginV = self.bottomView.subviews.firstObject;
    fastLoginV.frame = self.bottomView.bounds;
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)switchLoninOrRegister:(UIButton *)sender {
    sender.selected = !sender.selected;
    _middleVLeadingConstraint.constant = (_middleVLeadingConstraint.constant == 0) ? -self.middleV.width * 0.5 : 0;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (UIStatusBarStyle) preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
