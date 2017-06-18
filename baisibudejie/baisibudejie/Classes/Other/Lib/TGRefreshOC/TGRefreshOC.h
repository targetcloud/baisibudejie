//
//  TGRefreshOC.h
//  baisibudejie
//
//  Created by targetcloud on 2017/6/19.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,TGRefreshKind) {
    RefreshKindQQ,
    RefreshKindNormal,
};

typedef NS_ENUM(NSInteger,TGRefreshAlignment) {
    TGRefreshAlignmentTop,
    TGRefreshAlignmentMidden,
    TGRefreshAlignmentBottom,
};

@interface TGRefreshOC : UIControl
@property(nonatomic,assign) TGRefreshKind kind;//类型，默认为QQ
@property(nonatomic,strong) UIColor * bgColor;//背景色
@property(nonatomic,strong) UIColor * tinColor;//主题色（刷新文字颜色、ActivityIndicator颜色、橡皮筯颜色）
@property(nonatomic,assign) TGRefreshAlignment verticalAlignment;//垂直对齐，默认顶部
@property(nonatomic,copy) NSString * refreshSuccessStr;//刷新成功
@property(nonatomic,copy) NSString * refreshNormalStr;//准备刷新
@property(nonatomic,copy) NSString * refreshPullingStr;//即将刷新
@property(nonatomic,copy) NSString * refreshingStr;//正在刷新

@property(nonatomic,copy) NSString * refreshResultStr;//更新结果
@property(nonatomic,strong) UIColor * refreshResultBgColor;//更新结果的背景色
@property(nonatomic,strong) UIColor * refreshResultTextColor;//更新结果的文字颜色
@property(nonatomic,assign) CGFloat refreshResultHeight;//更新结果的高度

@property(nonatomic,assign) BOOL automaticallyChangeAlpha;//自动改变透明度

-(void)beginRefreshing;
-(void)endRefreshing;
@end
