//
//  TGTagTextField.h
//  baisibudejie
//
//  Created by targetcloud on 2017/5/20.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGTagTextField : UITextField
@property (nonatomic, copy) void(^deleteBlock)();
@end
