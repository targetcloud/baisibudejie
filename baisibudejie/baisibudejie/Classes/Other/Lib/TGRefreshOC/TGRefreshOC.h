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
/** 类型，默认为QQ弹簧 皮筋效果 */
@property(nonatomic,assign) TGRefreshKind kind;
/** 背景色（在有contentInset时为scrollview等背景色） */
@property(nonatomic,strong) UIColor * bgColor;
/** 主题色（刷新文字颜色、ActivityIndicator颜色、橡皮筯颜色） */
@property(nonatomic,strong) UIColor * tinColor;
/** 垂直对齐，默认顶部 */
@property(nonatomic,assign) TGRefreshAlignment verticalAlignment;
/** 刷新成功时的提示文字 */
@property(nonatomic,copy) NSString * refreshSuccessStr;
/** 准备刷新时的提示文字 */
@property(nonatomic,copy) NSString * refreshNormalStr;
/** 即将刷新时的提示文字 */
@property(nonatomic,copy) NSString * refreshPullingStr;
/** 正在刷新时的提示文字 */
@property(nonatomic,copy) NSString * refreshingStr;
/** 更新结果的回显文字 */
@property(nonatomic,copy) NSString * refreshResultStr;
/** 更新结果的回显背景色 */
@property(nonatomic,strong) UIColor * refreshResultBgColor;
/** 更新结果的回显文字颜色 */
@property(nonatomic,strong) UIColor * refreshResultTextColor;
/** 更新结果的回显高度 */
@property(nonatomic,assign) CGFloat refreshResultHeight;
/** 自动改变透明度，默认已做优化 */
@property(nonatomic,assign) BOOL automaticallyChangeAlpha;

-(TGRefreshOC * (^)(TGRefreshKind))tg_kind;
-(TGRefreshOC * (^)(UIColor *))tg_bgColor;
-(TGRefreshOC * (^)(UIColor *))tg_tinColor;
-(TGRefreshOC * (^)(TGRefreshAlignment))tg_verticalAlignment;
-(TGRefreshOC * (^)(NSString *))tg_refreshSuccessStr;
-(TGRefreshOC * (^)(NSString *))tg_refreshNormalStr;
-(TGRefreshOC * (^)(NSString *))tg_refreshPullingStr;
-(TGRefreshOC * (^)(NSString *))tg_refreshingStr;
-(TGRefreshOC * (^)(NSString *))tg_refreshResultStr;
-(TGRefreshOC * (^)(UIColor *))tg_refreshResultBgColor;
-(TGRefreshOC * (^)(UIColor *))tg_refreshResultTextColor;
-(TGRefreshOC * (^)(CGFloat))tg_refreshResultHeight;
-(TGRefreshOC * (^)(BOOL))tg_automaticallyChangeAlpha;

-(instancetype) initWithConfig:(void(^)(TGRefreshOC * refresh)) block;
+(instancetype) refreshWithTarget:(id)target action:(SEL)action config:(void(^)(TGRefreshOC * refresh)) block;

-(void)beginRefreshing;
-(void)endRefreshing;
@end
