//
//  TGRefreshOC.m
//  baisibudejie
//
//  Created by targetcloud on 2017/6/19.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGRefreshOC.h"

#define kBeginHeight 40.0//启始高度
#define kDragHeight 90.0//拖拽高度
#define kCenter CGPointMake(self.bounds.size.width * 0.5, kBeginHeight * 0.5)//启始圆心
#define kRadius 15.0//启始半径

typedef NS_ENUM(NSInteger, TGRefreshState) {
    RefreshStateNormal,
    RefreshStatePulling,
    RefreshStateRefresh,
};

@interface TGRefreshOC()
@property (assign ,nonatomic) CGFloat deltaH;
@property (weak, nonatomic) UIScrollView *sv;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (assign, nonatomic,getter=isAnimating) BOOL animating;
@property (assign, nonatomic,getter=isRefreshing) BOOL refreshing;
@property (assign,nonatomic) TGRefreshState refreshState;
@property (weak,nonatomic) UIImageView *innerImageView;
@property (weak,nonatomic) UIImageView *tipIcon;
@property (weak,nonatomic) UILabel *tipLabel;
@property (weak,nonatomic) UILabel *resultLabel;
@end

@implementation TGRefreshOC
{
    CGFloat initInsetTop_;
}

#pragma mark : - 创建相关
-(instancetype) initWithConfig:(void(^)(TGRefreshOC * refresh)) block{
    if (self = [super init]){
        !block? : block(self);
    }
    return self;
}

+(instancetype) refreshWithTarget:(id)target action:(SEL)action config:(void(^)(TGRefreshOC * refresh)) block{
    TGRefreshOC * refresh = [[self alloc] initWithConfig:block];
    [refresh addTarget:target action:action forControlEvents:UIControlEventValueChanged];
    return refresh;
}

#pragma mark : - KVO相关
-(void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    self.sv = (UIScrollView *)newSuperview;
    initInsetTop_ = self.sv.contentInset.top;
    self.backgroundColor = self.bgColor;
    self.frame = CGRectMake(0, -kBeginHeight, newSuperview.bounds.size.width, kBeginHeight);
    self.clipsToBounds = YES;
    [self.sv addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

-(void) removeFromSuperview{
    [self.superview removeObserver:self forKeyPath:@"contentOffset"];
    [super removeFromSuperview];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint point = [change[@"new"] CGPointValue];
        CGFloat height = initInsetTop_>0 ? -(initInsetTop_ + point.y) : -(point.y);//有初始的inset则不用背景色
        if( height <= 0) {
            return;
        }
        self.frame = CGRectMake(0, -height-initInsetTop_, self.sv.bounds.size.width, height);
        
        switch (_kind) {
            case RefreshKindQQ:{
                if (_animating || _refreshing || self.refreshState == RefreshStateRefresh) {//动画中 刷新中 已经在计时缩小过程中 已经在刷新状态
                    return;
                }
                _deltaH = fmaxf(0, -point.y - kBeginHeight - initInsetTop_);
                self.innerImageView.center = kCenter;
                [self setNeedsDisplay];
                if (-point.y > kDragHeight + initInsetTop_) {
                    [self beginRefreshing];
                }
            }
                break;
            case RefreshKindNormal:{
                if (self.refreshState == RefreshStateRefresh){
                    return;
                }else if (self.sv.dragging) {
                    if ((height > kBeginHeight) && (self.refreshState == RefreshStateNormal)){
                        self.refreshState = RefreshStatePulling;
                    }else if ((height <= kBeginHeight) && (self.refreshState == RefreshStatePulling)){
                        self.refreshState = RefreshStateNormal;
                    }else if (height <= kBeginHeight){
                        self.refreshState = RefreshStateNormal;
                    }
                }else{
                    if (self.refreshState == RefreshStatePulling){
                        [self beginRefreshing];
                    }
                }
                self.tipLabel.alpha = self.automaticallyChangeAlpha ? (height/kBeginHeight) :
                (self.verticalAlignment == TGRefreshAlignmentTop ? (height/kBeginHeight) : 1);
                self.tipIcon.alpha = self.tipLabel.alpha;
                [self setNeedsDisplay];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark : - setter方法相关
-(void) setRefreshState:(TGRefreshState)refreshState{
    _refreshState = refreshState;
    switch (_kind) {
        case RefreshKindNormal:
            
            [self normal:refreshState];
            break;
        case RefreshKindQQ:
            
            break;
        default:
            break;
    }
}

-(void) normal :(TGRefreshState)refreshState {
    self.tipIcon.image = [self getImage:@"normal@2x"];
    [self.tipIcon sizeToFit];
    switch (refreshState) {
        case RefreshStateNormal:{
            self.tipIcon.hidden = NO;
            self.tipLabel.hidden = NO;
            [self.activityIndicatorView stopAnimating];
            self.tipLabel.text = self.refreshNormalStr;
            [UIView animateWithDuration:0.25 animations:^{
                self.tipIcon.transform =  CGAffineTransformIdentity;
            }];
        }
            break;
        case RefreshStatePulling:{
            self.tipIcon.hidden = NO;
            self.tipLabel.hidden = NO;
            self.tipLabel.text = self.refreshPullingStr;
            [UIView animateWithDuration:0.25 animations:^{
                self.tipIcon.transform = CGAffineTransformRotate(self.transform, M_PI + 0.001);
            }];
        }
            break;
        case RefreshStateRefresh:
            self.tipLabel.hidden = NO;
            self.tipLabel.text = self.refreshingStr;
            self.tipIcon.hidden = YES;
            [self.activityIndicatorView startAnimating];
            break;
        default:
            self.tipIcon.hidden = NO;
            self.tipLabel.hidden = NO;
            [self.activityIndicatorView stopAnimating];
            self.tipLabel.text = self.refreshNormalStr;
            break;
    }
}

#pragma mark : - 刷新和结束刷新
-(void)beginRefreshing{
    if (self.refreshState == RefreshStateRefresh){
        return;
    }
    self.refreshState = RefreshStateRefresh;
    [UIView animateWithDuration:0.25 animations:^{
        UIEdgeInsets insets = self.sv.contentInset;
        insets.top += kBeginHeight;
        self.sv.contentInset = insets;
    } completion:^(BOOL finished) {
        
    }];
    switch (_kind) {
        case RefreshKindQQ:{
            if (!_animating){
                _animating = YES;
                [UIView animateWithDuration:0.25 animations:^{
                    _deltaH = 0;
                    [self setNeedsDisplay];
                } completion:^(BOOL finished) {
                    self.sv.contentOffset = CGPointMake(0, -(kBeginHeight + initInsetTop_));
                    _animating = NO;
                    _refreshing = YES;
                    [self.activityIndicatorView startAnimating];
                    _innerImageView.hidden = YES;
                }];
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
        }
            break;
        case RefreshKindNormal:{
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
            break;
        default:
            break;
    }
}

-(void) layoutSubviews{
    [super layoutSubviews];
    [self.tipLabel sizeToFit];
    switch (_kind) {
        case RefreshKindQQ:
            self.alpha = self.frame.size.height/kBeginHeight;
            //            self.activityIndicatorView.center = CGPointMake(kCenter.x, initInsetTop_ > 0 ? -kCenter.y : kCenter.y);
            self.activityIndicatorView.center = kCenter;
            break;
        case RefreshKindNormal:
            switch (_verticalAlignment) {
                case TGRefreshAlignmentTop:
                    //                    self.tipLabel.center = kCenter;
                    self.tipLabel.center = CGPointMake(self.bounds.size.width * 0.5,initInsetTop_ + kBeginHeight * 0.5);
                    break;
                case TGRefreshAlignmentMidden:
                    //                    self.tipLabel.center = CGPointMake(self.bounds.size.width * 0.5,fabs(self.frame.origin.y*0.5));
                    self.tipLabel.center = CGPointMake(self.bounds.size.width * 0.5,initInsetTop_ + (fabs(self.frame.origin.y) - initInsetTop_)* 0.5);
                    break;
                case TGRefreshAlignmentBottom:
                    self.tipLabel.center = CGPointMake(self.bounds.size.width * 0.5,fabs(self.frame.origin.y) - kBeginHeight * 0.5 );
                    break;
                default:
                    self.tipLabel.center = CGPointMake(self.bounds.size.width * 0.5,fabs(self.frame.origin.y) - kBeginHeight * 0.5 );
                    break;
            }
            self.tipLabel.center = CGPointMake(self.tipLabel.center.x, self.tipLabel.center.y - initInsetTop_);
            
            self.tipIcon.center = CGPointMake(self.tipLabel.frame.origin.x - self.tipIcon.frame.size.width - 3, self.tipLabel.center.y);
            self.activityIndicatorView.center = self.tipIcon.center;
            break;
        default:
            break;
    }
}

-(void)endRefreshing{
    self.tipIcon.transform =  CGAffineTransformIdentity;
    _refreshing = NO;
    _animating = NO;
    self.tipLabel.text = self.refreshSuccessStr;
    self.tipIcon.image = [self getImage:@"tipok@2x"];
    [self.tipLabel sizeToFit];
    [self.tipIcon sizeToFit];
    self.tipLabel.center = self.activityIndicatorView.center;
    
    self.tipIcon.center = CGPointMake((self.tipLabel.frame.size.width < 1 ?
                                       self.activityIndicatorView.center.x :
                                       (self.tipLabel.frame.origin.x - (self.tipIcon.frame.size.width + 3))),
                                      self.activityIndicatorView.center.y);
    self.tipIcon.hidden = NO;
    self.tipLabel.hidden = NO;
    [self.activityIndicatorView stopAnimating];
    self.tipLabel.alpha = 0.1;
    [UIView animateWithDuration:0.25 animations:^{
        self.tipLabel.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            self.tipIcon.hidden = YES;
            self.tipLabel.hidden = YES;
            UIEdgeInsets inset = self.sv.contentInset;
            inset.top -= kBeginHeight;
            self.sv.contentInset = inset;
        } completion:^(BOOL finished) {
            if (self.refreshResultStr.length>0){
                self.resultLabel.alpha = 0.5;
                self.resultLabel.transform = CGAffineTransformMakeTranslation(0, -self.refreshResultHeight);
                
                self.resultLabel.text = self.refreshResultStr;
                [UIView animateWithDuration:1 animations:^{
                    self.resultLabel.transform = CGAffineTransformIdentity;
                    self.resultLabel.alpha = 1;
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:2 animations:^{
                        self.resultLabel.transform = CGAffineTransformMakeTranslation(0, -self.refreshResultHeight);
                        self.resultLabel.alpha = 0;
                        _refreshState = RefreshStateNormal;
                        _refreshResultStr = @"";
                    }];
                }];
            }else{
                _refreshState = RefreshStateNormal;
                _refreshResultStr = @"";
            }
        }];
    }];
}

#pragma mark : - 懒加载
-(UIImageView *) innerImageView{
    if (!_innerImageView){
        UIImageView * iv = [[UIImageView alloc] initWithImage:[self getImage:@"refresh@2x"]];
        [self addSubview:iv];
        _innerImageView = iv;
    }
    return _innerImageView;
}

-(UIImageView *) tipIcon{
    if (!_tipIcon){
        UIImageView * iv = [[UIImageView alloc] initWithImage:[self getImage:@"tipok@2x"]];
        iv.hidden = YES;
        [self addSubview:iv];
        _tipIcon = iv;
    }
    return _tipIcon;
}

-(UILabel *) tipLabel{
    if (!_tipLabel){
        UILabel * lbl = [[UILabel alloc] init];
        lbl.font = [UIFont systemFontOfSize:11];
        lbl.backgroundColor = [UIColor clearColor];
        [lbl setTextColor:self.tinColor];
        [self addSubview:lbl];
        _tipLabel = lbl;
    }
    return _tipLabel;
}

-(UILabel *) resultLabel{
    if (!_resultLabel){
        UILabel * lbl = [[UILabel alloc] init];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize:12];
        lbl.backgroundColor = self.refreshResultBgColor;
        [lbl setTextColor:self.refreshResultTextColor];
        lbl.frame = CGRectMake(self.sv.frame.origin.x, -initInsetTop_, self.sv.frame.size.width, self.refreshResultHeight);
        [self.sv addSubview:lbl];
        _resultLabel = lbl;
    }
    return _resultLabel;
}

-(UIActivityIndicatorView *) activityIndicatorView{
    if (!_activityIndicatorView) {
        UIActivityIndicatorView *act = [UIActivityIndicatorView new];
        act.transform = CGAffineTransformMakeScale(.7f, .7f);
        act.center = kCenter;
        act.color = self.tinColor;
        [self addSubview:act];
        _activityIndicatorView = act;
    }
    return _activityIndicatorView;
}

-(UIColor *) bgColor{
    UIColor * color = _bgColor ?  (initInsetTop_ > 0 ? self.sv.backgroundColor : _bgColor) : self.sv.backgroundColor;
    CGFloat r;
    CGFloat g;
    CGFloat b;
    CGFloat a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    color = [UIColor colorWithRed:r green:g blue:b alpha:1];
    return color;
}

-(UIColor *) tinColor{
    return _tinColor ?  _tinColor : [UIColor grayColor];
}

-(NSString *) refreshSuccessStr{
    return _refreshSuccessStr ? _refreshSuccessStr : @"刷新成功";
}

-(NSString *) refreshNormalStr{
    return _refreshNormalStr ? _refreshNormalStr : @"下拉可以刷新";
}

-(NSString *) refreshPullingStr{
    return _refreshPullingStr ? _refreshPullingStr : @"松开立即刷新";
}

-(NSString *) refreshingStr{
    return _refreshingStr ? _refreshingStr : @"正在刷新数据中...";
}

-(UIColor *) refreshResultBgColor{
    return _refreshResultBgColor ? _refreshResultBgColor : [self.tinColor colorWithAlphaComponent:0.8];
}

-(UIColor *) refreshResultTextColor{
    return _refreshResultTextColor ? _refreshResultTextColor : [UIColor whiteColor];
}

-(CGFloat) refreshResultHeight{
    return _refreshResultHeight ? _refreshResultHeight : 34;
}

#pragma mark : - 控件相关
-(void)drawRect:(CGRect)rect{
    if (!CGPointEqualToPoint(self.innerImageView.center,kCenter)){
        return;
    }
    switch (_kind) {
        case RefreshKindQQ:
            
            break;
            
        default:
            [self.bgColor setFill];
            return;
            break;
    }
    
    if (_refreshing) {
        return;
    }
    
    CGPoint startCenter = kCenter;
    
    _deltaH = _deltaH>(kDragHeight - kBeginHeight)? (kDragHeight - kBeginHeight) : _deltaH;
    
    CGFloat radTop = kRadius - _deltaH * 0.1;
    CGFloat radBottom = kRadius - _deltaH * 0.2;
    CGFloat Y = fmaxf(_deltaH, 0);
    
    CGFloat radBottomLeftAndRight = 0;
    if ((radTop - radBottom) > 0) {
        radBottomLeftAndRight = (pow(Y, 2)+pow(radBottom, 2)-pow(radTop, 2))/(2*(radTop - radBottom));
    }
    radBottomLeftAndRight = fmax(0, radBottomLeftAndRight);
    
    CGPoint centerBottom = relative(startCenter, 0, Y);
    CGPoint centerRight = relative(centerBottom, radBottom+radBottomLeftAndRight, 0);
    CGPoint centerLeft = relative(centerBottom, -radBottom-radBottomLeftAndRight, 0);
    
    UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:startCenter radius:radTop startAngle:0 endAngle:2*M_PI clockwise:1];
    
    self.innerImageView.bounds = CGRectMake(0, 0,radTop*2*0.6, radTop*2*0.6);
    self.innerImageView.hidden = NO;
    
    if (_deltaH <= 0){
        [self.tinColor setFill];
        [circle fill];
        return;
    }
    
    [circle moveToPoint:centerBottom];
    [circle addArcWithCenter:centerBottom radius:radBottom startAngle:0 endAngle:2*M_PI clockwise:1];
    
    UIBezierPath *circle2 = [UIBezierPath bezierPathWithArcCenter:centerRight radius:radBottomLeftAndRight startAngle:0 endAngle:2*M_PI clockwise:1];
    [circle2 moveToPoint:centerLeft];
    [circle2 addArcWithCenter:centerLeft radius:radBottomLeftAndRight startAngle:0 endAngle:2*M_PI clockwise:1];
    
    UIBezierPath *line = [UIBezierPath bezierPath];
    [line moveToPoint:startCenter];
    [line addLineToPoint:centerRight];
    [line addLineToPoint:centerBottom];
    [line addLineToPoint:centerLeft];
    [line closePath];
    [line appendPath:circle];
    [self.tinColor setFill];
    [line fill];
    [self.bgColor setFill];
    [circle2 fill];
}

CGPoint relative(CGPoint point, CGFloat x, CGFloat y){
    return CGPointMake(point.x + x, point.y + y);
}

#pragma mark : - 资源相关
-(UIImage *)getImage:(NSString *)name{
    NSBundle *currentBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[TGRefreshOC class]] pathForResource:@"TGRefreshOC" ofType:@"bundle"]];
    UIImage *img =  [UIImage imageWithContentsOfFile:[currentBundle pathForResource:name ofType:@"png"]];
    return img;
}

#pragma mark : - 链式配置相关
-(TGRefreshOC * (^)(TGRefreshKind))tg_kind{
    return ^(TGRefreshKind kind){
        self.kind = kind;
        return self;
    };
}

-(TGRefreshOC * (^)(UIColor *))tg_bgColor{
    return ^(UIColor *color){
        CGFloat r;
        CGFloat g;
        CGFloat b;
        CGFloat a;
        [color getRed:&r green:&g blue:&b alpha:&a];
        color = [UIColor colorWithRed:r green:g blue:b alpha:1];
        self.bgColor = color;
        return self;
    };
}

-(TGRefreshOC * (^)(UIColor *))tg_tinColor{
    return ^(UIColor *color){
        self.tinColor = color;
        return self;
    };
}

-(TGRefreshOC * (^)(TGRefreshAlignment))tg_verticalAlignment{
    return ^(TGRefreshAlignment vl){
        self.verticalAlignment = vl;
        return self;
    };
}

-(TGRefreshOC * (^)(NSString *))tg_refreshSuccessStr{
    return ^(NSString *str){
        self.refreshSuccessStr = str;
        return self;
    };
}

-(TGRefreshOC * (^)(NSString *))tg_refreshNormalStr{
    return ^(NSString *str){
        self.refreshNormalStr = str;
        return self;
    };
}

-(TGRefreshOC * (^)(NSString *))tg_refreshPullingStr{
    return ^(NSString *str){
        self.refreshPullingStr = str;
        return self;
    };
}

-(TGRefreshOC * (^)(NSString *))tg_refreshingStr{
    return ^(NSString *str){
        self.refreshingStr = str;
        return self;
    };
}

-(TGRefreshOC * (^)(NSString *))tg_refreshResultStr{
    return ^(NSString *str){
        self.refreshResultStr = str;
        return self;
    };
}

-(TGRefreshOC * (^)(UIColor *))tg_refreshResultBgColor{
    return ^(UIColor *color){
        self.refreshResultBgColor = color;
        return self;
    };
}

-(TGRefreshOC * (^)(UIColor *))tg_refreshResultTextColor{
    return ^(UIColor *color){
        self.refreshResultTextColor = color;
        return self;
    };
}

-(TGRefreshOC * (^)(CGFloat))tg_refreshResultHeight{
    return ^(CGFloat height){
        self.refreshResultHeight = height;
        return self;
    };
}

-(TGRefreshOC * (^)(BOOL))tg_automaticallyChangeAlpha{
    return ^(BOOL autoAlpha){
        self.automaticallyChangeAlpha = autoAlpha;
        return self;
    };
}

@end
