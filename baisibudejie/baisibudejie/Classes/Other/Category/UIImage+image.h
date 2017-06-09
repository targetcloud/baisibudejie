//
//  UIImage+image.h
//  baisibudejie
//
//  Created by targetcloud on 2017/3/5.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (image)
+ (UIImage *)imageOriginalWithName:(NSString *)imageName;
- (instancetype)tg_circleImage;
+ (instancetype)tg_circleImageNamed:(NSString *)name;
+ (UIImage *)imageWithColor:(UIColor *)color andRect:(CGRect )rect;
+ (instancetype)tg_circleImageNamed:(NSString *)name borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
- (instancetype)tg_circleImageBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
@end
