//
//  TGTagTextField.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/20.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGTagTextField.h"

@implementation TGTagTextField

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.placeholder = @"多个标签用换行或者逗号隔开!";
        [self setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
        self.height = TagH;
    }
    return self;
}

- (void)deleteBackward{
    !_deleteBlock ? : _deleteBlock();
    [super deleteBackward];
}

@end
