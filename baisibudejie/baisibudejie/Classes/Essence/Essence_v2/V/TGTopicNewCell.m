//
//  TGTopicNewCell.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/30.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGTopicNewCell.h"
#import "TGTopicNewM.h"
#import "TGCommentNewM.h"
#import "TGUserNewM.h"
#import "TGPicNewV.h"
#import "TGVideoNewV.h"
#import "TGVoiceNewV.h"
#import "TGTopCommentCell.h"
#import <UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface TGTopicNewCell()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *profileImageV;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *passtimeLbl;
@property (weak, nonatomic) IBOutlet UILabel *textLbl;
@property (weak, nonatomic) IBOutlet UIButton *dingBtn;
@property (weak, nonatomic) IBOutlet UIButton *caiBtn;
@property (weak, nonatomic) IBOutlet UIButton *repostBtn;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIView *topCmtV;
//@property (weak, nonatomic) IBOutlet UILabel *topCmtLbl;
@property (weak, nonatomic) IBOutlet UITableView *topCmtTableV;
@property (weak, nonatomic) IBOutlet UIView *toolBarV;

@property (weak, nonatomic) IBOutlet UIImageView *sinaV;
@property (weak, nonatomic) IBOutlet UIImageView *vip;

@property (weak, nonatomic) IBOutlet UIButton *spreadBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spreadViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topCommentViewConstraint;

@property (nonatomic, weak) TGPicNewV *picV;
@property (nonatomic, weak) TGVideoNewV *videoV;
@property (nonatomic, weak) TGVoiceNewV *voiceV;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (nonatomic, strong) UIButton *coverBtn;
@end

static NSString *const commentID = @"TGTopCommentCellID";

@implementation TGTopicNewCell

- (UIButton*)coverBtn{
    if (!_coverBtn) {
        _coverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _coverBtn.frame = self.dingBtn.frame;
        _coverBtn.alpha = 0;
        [_coverBtn setImage:[UIImage imageNamed:@"timeline_icon_like"] forState:UIControlStateSelected];
        [_coverBtn setImage:[UIImage imageNamed:@"timeline_icon_like"] forState:UIControlStateNormal];
    }
    return _coverBtn;
}

- (TGVoiceNewV *)voiceV{
    if (!_voiceV) {
        TGVoiceNewV *voiceV = [TGVoiceNewV viewFromXIB];
        [self.contentView addSubview:voiceV];
        _voiceV = voiceV;
    }
    return _voiceV;
}

- (TGPicNewV *)picV{
    if (!_picV) {
        TGPicNewV *picV = [TGPicNewV viewFromXIB];
        [self.contentView addSubview:picV];
        _picV = picV;
    }
    return _picV;
}

- (TGVideoNewV *)videoV{
    if (!_videoV) {
        TGVideoNewV *videoV = [TGVideoNewV viewFromXIB];
        [self.contentView addSubview:videoV];
        _videoV = videoV;
    }
    return _videoV;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    //self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainCellBackground"]];
    self.textLbl.font = [UIFont systemFontOfSize:14];
    self.topCmtTableV.dataSource = self;
    self.topCmtTableV.delegate = self;
    [self.topCmtTableV registerNib:[UINib nibWithNibName:NSStringFromClass([TGTopCommentCell class]) bundle:nil] forCellReuseIdentifier:commentID];
    self.topCmtTableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.topCmtTableV.backgroundColor = [UIColor clearColor];
    //self.topCmtLbl.font = [UIFont systemFontOfSize:12];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.topic.top_comments.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TGTopCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:commentID forIndexPath:indexPath];
    cell.commentM = self.topic.top_comments[indexPath.row];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //TGLog(@"%f",self.topic.top_comments[indexPath.row].topCommentCellHeight)
    return  self.topic.top_comments[indexPath.row].topCommentCellHeight;
}

- (void)setTopic:(TGTopicNewM *)topic{
    _topic = topic;
    
    self.sinaV.hidden = !topic.u.is_v;
    self.vip.hidden = !topic.u.is_vip;
    
    [self.nameLbl setTextColor:topic.u.is_vip ? TGColor(240, 77, 71) : TGColor(0, 128, 128) ];
    
    [self.profileImageV tg_setHeader:topic.u.header];
    
    self.nameLbl.text = topic.u.name;
    self.passtimeLbl.text = topic.passtime;
    self.textLbl.text = topic.text;
    [self setupButtonTitle:self.dingBtn number:topic.up placeholder:@"顶"];
    [self setupButtonTitle:self.caiBtn number:topic.down placeholder:@"踩"];
    [self setupButtonTitle:self.repostBtn number:topic.forward placeholder:@"分享"];
    [self setupButtonTitle:self.commentBtn number:topic.comment placeholder:@"评论"];
    self.dingBtn.selected = self.topic.isUpSelected;
    self.caiBtn.selected = self.topic.isDownSelected;
    
    self.topCmtV.hidden = topic.top_comments.count <= 0 ;
    if (topic.top_comments.count){
        self.topCommentViewConstraint.constant = topic.commentVH;
        [self.topCmtTableV reloadData];
        //self.topCmtLbl.attributedText = topic.attrStrM;
    }
    
    self.spreadV.hidden = (topic.textHeight <= TextHeightConstraint);
    self.textHeightConstraint.constant = self.topic.textHeight > TextHeightConstraint? TextHeightConstraint : self.topic.textHeight;
    if (!self.spreadV.hidden){
        [self.spreadBtn setTitle:topic.cellHeight > self.topic.defaultHeight ? @"收缩" : @"展开" forState:UIControlStateNormal];
        self.textHeightConstraint.constant = self.topic.isShowAllWithoutComment ?  self.topic.textHeight : topic.cellHeight > self.topic.defaultHeight ? self.topic.textHeight : TextHeightConstraint;
        self.spreadViewBottomConstraint.constant = topic.cellHeight > self.topic.defaultHeight ? 19.f : 0;
    }
    
    self.picV.hidden = !([topic.type.lowercaseString isEqualToString:@"image"] || [topic.type.lowercaseString isEqualToString:@"gif"]);
    self.videoV.hidden = !([topic.type.lowercaseString isEqualToString:@"video"]);
    self.voiceV.hidden = !([topic.type.lowercaseString isEqualToString:@"audio"]);
    if ([topic.type.lowercaseString isEqualToString:@"image"] || [topic.type.lowercaseString isEqualToString:@"gif"]) { // 图片
        self.picV.topic = topic;
    } else if ([topic.type.lowercaseString isEqualToString:@"audio"]) { // 声音
        self.voiceV.topic = topic;
    }else if ([topic.type.lowercaseString isEqualToString:@"video"]) { // 视频
        self.videoV.topic = topic;
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if ([self.topic.type.lowercaseString isEqualToString:@"image"] || [self.topic.type.lowercaseString isEqualToString:@"gif"]) { // 图片
        self.picV.frame = self.topic.middleFrame;
    } else if ([self.topic.type.lowercaseString isEqualToString:@"audio"]) { // 声音
        self.voiceV.frame = self.topic.middleFrame;
    }else if ([self.topic.type.lowercaseString isEqualToString:@"video"]) { // 视频
        self.videoV.frame = self.topic.middleFrame;
    }
}

- (void)setupButtonTitle:(UIButton *)button number:(NSInteger)number placeholder:(NSString *)placeholder{
    if (number >= 10000) {
        [button setTitle:[NSString stringWithFormat:@"%.1f万", number / 10000.0] forState:UIControlStateNormal];
    } else if (number > 0) {
        [button setTitle:[NSString stringWithFormat:@"%zd", number] forState:UIControlStateNormal];
    } else {
        [button setTitle:placeholder forState:UIControlStateNormal];
    }
}

- (void)setFrame:(CGRect)frame{
    //frame.size.height += 1;//不采用背景图做为分隔,直接在cell里加一个0.5高度的view作为分隔线
    [super setFrame:frame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (IBAction)more:(id)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [controller addAction:[UIAlertAction actionWithTitle:@"评论" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        !_commentBlock ? : _commentBlock(self.topic.ID);
    }]];
    
    [controller addAction:[UIAlertAction actionWithTitle:@"收藏" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        TGLog(@"点击了[收藏]按钮")
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"举报" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        TGLog(@"点击了[举报]按钮")
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        TGLog(@"点击了[取消]按钮")
    }]];
    [self.window.rootViewController presentViewController:controller animated:YES completion:nil];
}

- (IBAction)spreadBtnClick:(UIButton *)sender {
    [self.spreadBtn setTitle: ([self.spreadBtn.currentTitle isEqualToString:@"展开"] ? @"收缩" : @"展开" ) forState:UIControlStateNormal];
    
    self.topic.middleFrame = CGRectMake(self.topic.middleFrame.origin.x,
                                        [self.spreadBtn.currentTitle isEqualToString:@"收缩"] ?  self.topic.middleY + (self.topic.textHeight + 19.f - TextHeightConstraint) : self.topic.middleY,
                                        self.topic.middleFrame.size.width,
                                        self.topic.middleFrame.size.height);
    
    [self.topic setValue:@( [self.spreadBtn.currentTitle isEqualToString:@"收缩"] ? self.topic.cellHeight + (self.topic.textHeight + 19.f - TextHeightConstraint) : self.topic.defaultHeight) forKey:@"cellHeight" ];
    !(self.block) ? : self.block();
}

- (IBAction)upClick:(UIButton *)sender {
    !_upBlock ? : _upBlock(self.topic.ID);
    
    if (!self.dingBtn.selected) {
        [self.coverBtn removeFromSuperview];
        [self.toolBarV insertSubview:self.coverBtn belowSubview:self.dingBtn];
        self.coverBtn.frame = self.dingBtn.imageView.frame;
        [self.coverBtn setImage:[UIImage imageNamed:@"timeline_icon_like"] forState:UIControlStateSelected];
        [self.coverBtn setImage:[UIImage imageNamed:@"timeline_icon_like"] forState:UIControlStateNormal];
        self.userInteractionEnabled = NO;
        self.coverBtn.alpha = 1;
        [UIView animateWithDuration:1.0f animations:^{
            self.coverBtn.y -= 50;
            CAKeyframeAnimation *anima = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
            NSValue *value1 = [NSNumber numberWithFloat:-M_PI/180*5];
            NSValue *value2 = [NSNumber numberWithFloat:M_PI/180*5];
            NSValue *value3 = [NSNumber numberWithFloat:-M_PI/180*5];
            anima.values = @[value1,value2,value3];
            anima.repeatCount = MAXFLOAT;
            [self.coverBtn.layer addAnimation:anima forKey:nil];
            self.coverBtn.alpha = 0;
        } completion:^(BOOL finished) {
            self.coverBtn.frame = self.dingBtn.imageView.frame;
            self.userInteractionEnabled = YES;
        }];
    }
    
    self.topic.up += self.topic.upSelected ? -1 : 1;
    self.topic.upSelected = !self.topic.upSelected;
    self.dingBtn.selected = !self.dingBtn.selected;
    [self setupButtonTitle:self.dingBtn number:self.topic.up placeholder:@"顶"];
}

- (IBAction)downClick:(UIButton *)sender {
    !_downBlock ? : _downBlock(self.topic.ID);
    
    if (!self.caiBtn.selected) {
        [self.coverBtn removeFromSuperview];
        [self.toolBarV insertSubview:self.coverBtn belowSubview:self.caiBtn];
        self.coverBtn.frame = self.caiBtn.imageView.frame;
        self.coverBtn.x += CGRectGetMaxX(self.dingBtn.frame);
        [self.coverBtn setImage:[UIImage imageNamed:@"icon_unlike_h"] forState:UIControlStateSelected];
        [self.coverBtn setImage:[UIImage imageNamed:@"icon_unlike_h"] forState:UIControlStateNormal];
        self.userInteractionEnabled = NO;
        self.coverBtn.alpha = 1;
        [UIView animateWithDuration:1.0f animations:^{
            self.coverBtn.transform = CGAffineTransformMakeScale(2, 2);
            CAKeyframeAnimation *anima = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
            NSValue *value1 = [NSNumber numberWithFloat:-M_PI/180*5];
            NSValue *value2 = [NSNumber numberWithFloat:M_PI/180*5];
            NSValue *value3 = [NSNumber numberWithFloat:-M_PI/180*5];
            anima.values = @[value1,value2,value3];
            anima.repeatCount = MAXFLOAT;
            [self.coverBtn.layer addAnimation:anima forKey:nil];
            
            self.coverBtn.alpha = 0;
        } completion:^(BOOL finished) {
            self.coverBtn.transform = CGAffineTransformIdentity;
            self.userInteractionEnabled = YES;
        }];
    }
    
    self.topic.down += self.topic.downSelected ? -1 : 1;
    self.topic.downSelected = !self.topic.downSelected;
    self.caiBtn.selected = !self.caiBtn.selected;
    [self setupButtonTitle:self.caiBtn number:self.topic.down placeholder:@"踩"];
}

- (IBAction)repostClick:(UIButton *)sender {
    !_repostBlock ? : _repostBlock(self.topic.ID);
}

- (IBAction)commentClick:(UIButton *)sender {
    !_commentBlock ? : _commentBlock(self.topic.ID);
}

@end
