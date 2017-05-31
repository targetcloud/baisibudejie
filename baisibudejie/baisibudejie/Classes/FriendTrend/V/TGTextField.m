//
//  TGTextField.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/7.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGTextField.h"
#import "UITextField+placeholder.h"

@implementation TGTextField

- (void)awakeFromNib{
    [super awakeFromNib];
    self.tintColor = [UIColor whiteColor];
    [self addTarget:self action:@selector(textBegin) forControlEvents:UIControlEventEditingDidBegin];
    [self addTarget:self action:@selector(textEnd) forControlEvents:UIControlEventEditingDidEnd];
    self.placeholderColor = [UIColor lightGrayColor];
}

- (void)textBegin{
    self.placeholderColor = [UIColor whiteColor];
}

- (void)textEnd{
    self.placeholderColor = [UIColor lightGrayColor];
}

@end
