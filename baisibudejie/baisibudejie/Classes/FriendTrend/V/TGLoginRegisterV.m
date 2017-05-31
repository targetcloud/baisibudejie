//
//  TGLoginRegisterV.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/7.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGLoginRegisterV.h"

@interface TGLoginRegisterV()
@property (weak, nonatomic) IBOutlet UIButton *loginRegisterBtn;

@end

@implementation TGLoginRegisterV

+(instancetype) loginView{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil][0];
}

+(instancetype) registerView{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil][1];
}

-(void) awakeFromNib{
    UIImage * img= _loginRegisterBtn.currentBackgroundImage;
    img = [img stretchableImageWithLeftCapWidth:img.size.width*0.5  topCapHeight:img.size.height*0.5];
    [_loginRegisterBtn setBackgroundImage:img forState:UIControlStateNormal];
}

@end
