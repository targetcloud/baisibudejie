//
//  TGAddTagsVC.h
//  baisibudejie
//
//  Created by targetcloud on 2017/5/21.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGAddTagsVC : UIViewController
@property (nonatomic, copy) void(^tagsBlock)(NSArray *tags);
@property (strong , nonatomic)NSArray *tags;
@end
