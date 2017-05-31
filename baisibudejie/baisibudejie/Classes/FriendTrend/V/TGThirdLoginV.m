//
//  TGThirdLoginV.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/7.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGThirdLoginV.h"

@implementation TGThirdLoginV

+ (instancetype)fastLoginView{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] firstObject];
}

@end
