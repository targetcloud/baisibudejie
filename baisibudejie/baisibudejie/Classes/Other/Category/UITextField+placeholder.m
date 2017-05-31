//
//  UITextField+placeholder.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/7.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "UITextField+placeholder.h"
#import <objc/message.h>

@implementation UITextField (placeHolder)

+ (void)load{
    Method setPlaceholderMethod = class_getInstanceMethod(self, @selector(setPlaceholder:));
    Method tg_setPlaceholderMethod = class_getInstanceMethod(self, @selector(tg_setPlaceholder:));
    method_exchangeImplementations(setPlaceholderMethod, tg_setPlaceholderMethod);
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor{
    objc_setAssociatedObject(self, @"placeholderColor", placeholderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    UILabel *placeholderLabel = [self valueForKey:@"placeholderLabel"];
    placeholderLabel.textColor = placeholderColor;
}

- (UIColor *)placeholderColor{
    return objc_getAssociatedObject(self, @"placeholderColor");
}

- (void)tg_setPlaceholder:(NSString *)placeholder{
    [self tg_setPlaceholder:placeholder];
    self.placeholderColor = self.placeholderColor;
}

@end
