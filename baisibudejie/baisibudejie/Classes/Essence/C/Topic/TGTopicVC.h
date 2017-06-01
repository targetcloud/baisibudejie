//
//  TGTopicVC.h
//  baisibudejie
//
//  Created by targetcloud on 2017/3/8.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGTopicM.h"

@interface TGTopicVC : UITableViewController
- (TGTopicType)type;//get   另外可以设计成带参数，这样父类可以传东西给子类           不设计成只读属性，是为不了不生成成员变量（KVC可以修改_成员变量的值）
- (BOOL) showAD;
@end
