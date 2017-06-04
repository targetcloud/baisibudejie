//
//  TGTopicCell.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/12.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGTopicCell.h"
#import "TGTopicM.h"
#import "TGCommentM.h"
#import "TGUserM.h"
#import "TGPicV.h"
#import "TGVideoV.h"
#import "TGVoiceV.h"
#import <UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface TGTopicCell()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageV;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *passtimeLbl;
@property (weak, nonatomic) IBOutlet UILabel *textLbl;
@property (weak, nonatomic) IBOutlet UIButton *dingBtn;
@property (weak, nonatomic) IBOutlet UIButton *caiBtn;
@property (weak, nonatomic) IBOutlet UIButton *repostBtn;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIView *topCmtV;
@property (weak, nonatomic) IBOutlet UILabel *topCmtLbl;
@property (weak, nonatomic) IBOutlet UIImageView *sinaV;
@property (nonatomic, weak) TGPicV *picV;
@property (nonatomic, weak) TGVoiceV *voiceV;
@property (nonatomic, weak) TGVideoV *videoV;
@property (weak, nonatomic) IBOutlet UIButton *voiceBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceBtnTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@end

static AVPlayer * top_cmt_player_;
static UIButton *lastPlayBtn_;
static TGCommentM *lastCommentM_;

@implementation TGTopicCell

- (TGPicV *)picV{
    if (!_picV) {
        TGPicV *picV = [TGPicV viewFromXIB];
        [self.contentView addSubview:picV];
        _picV = picV;
    }
    return _picV;
}

- (TGVoiceV *)voiceV{
    if (!_voiceV) {
        TGVoiceV *voiceV = [TGVoiceV viewFromXIB];
        [self.contentView addSubview:voiceV];
        _voiceV = voiceV;
    }
    return _voiceV;
}

- (TGVideoV *)videoV{
    if (!_videoV) {
        TGVideoV *videoV = [TGVideoV viewFromXIB];
        [self.contentView addSubview:videoV];
        _videoV = videoV;
    }
    return _videoV;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    //self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainCellBackground"]];
    self.textLbl.font = [UIFont systemFontOfSize:14];
    self.topCmtLbl.font = [UIFont systemFontOfSize:12];
    [self.voiceBtn setAdjustsImageWhenHighlighted:NO];
    UIImageView * imageView = self.voiceBtn.imageView;
    imageView.animationImages=[NSArray arrayWithObjects:
                               [UIImage imageNamed:@"play-voice-icon-0"],
                               [UIImage imageNamed:@"play-voice-icon-1"],
                               [UIImage imageNamed:@"play-voice-icon-2"],
                               nil ];
    imageView.animationDuration=1.0;
    imageView.animationRepeatCount = 0;
}

- (void)setTopic:(TGTopicM *)topic{
    _topic = topic;
    //移至imageView分类去
    /*
    UIImage *placeholder = [UIImage tg_circleImageNamed:@"defaultUserIcon"];
    [self.profileImageV sd_setImageWithURL:[NSURL URLWithString:topic.profile_image] placeholderImage:placeholder options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image) return;
        self.profileImageV.image = [image tg_circleImage];
    }];
    */
    self.sinaV.hidden = !topic.isSina_v;
    [self.profileImageV tg_setHeader:topic.profile_image];
    
    self.nameLbl.text = topic.name;
    self.passtimeLbl.text = topic.passtime;
    self.textLbl.text = topic.text;
    [self setupButtonTitle:self.dingBtn number:topic.ding placeholder:@"顶"];
    [self setupButtonTitle:self.caiBtn number:topic.cai placeholder:@"踩"];
    [self setupButtonTitle:self.repostBtn number:topic.repost placeholder:@"分享"];
    [self setupButtonTitle:self.commentBtn number:topic.comment placeholder:@"评论"];
    
    self.topCmtV.hidden = topic.top_cmt.content.length <= 0 && topic.top_cmt.voiceuri.length<=0;
    if (topic.top_cmt){
        /*
        NSDictionary * cmt = topic.top_cmt.firstObject;
        NSString *content = cmt[@"content"];
        if (content.length == 0) {
            content = @"[语音评论]";
        }
        NSString *username = cmt[@"user"][@"username"];
        self.topCmtLbl.text = [NSString stringWithFormat:@"%@ : %@", username, content];
         */
        NSString *content = topic.top_cmt.content;
        self.voiceBtn.hidden = topic.top_cmt.voiceuri.length<=0;
        
        if (content.length == 0) {
            content = @"";
            [self.voiceBtn setTitle:[NSString stringWithFormat:@"%zd''", topic.top_cmt.voicetime ] forState:UIControlStateNormal];
        }
        NSString *username = topic.top_cmt.user.username;
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString : [NSString stringWithFormat:@"%@ : %@", username,content]];
        [attrStr addAttribute:NSFontAttributeName
                        value:[UIFont systemFontOfSize:12.0f]
                        range:NSMakeRange(0, attrStr.length)];
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:TGColor(62, 114, 166)
                        range:NSMakeRange(0, username.length)];
        self.topCmtLbl.attributedText = attrStr;
    }
    
    self.picV.hidden = !(topic.type == TGTopicTypePicture);
    self.voiceV.hidden = !(topic.type == TGTopicTypeVoice);
    self.videoV.hidden = !(topic.type == TGTopicTypeVideo);
    if (topic.type == TGTopicTypePicture) { // 图片
//        self.picV.hidden = NO;
//        self.voiceV.hidden = YES;
//        self.videoV.hidden = YES;
        self.picV.topic = topic;
    } else if (topic.type == TGTopicTypeVoice) { // 声音
//        self.picV.hidden = YES;
//        self.voiceV.hidden = NO;
//        self.videoV.hidden = YES;
        self.voiceV.topic = topic;
    } else if (topic.type == TGTopicTypeVideo) { // 视频
//        self.picV.hidden = YES;
//        self.voiceV.hidden = YES;
//        self.videoV.hidden = NO;
        self.videoV.topic = topic;
    } else if (topic.type == TGTopicTypeWord) { // 段子
//        self.picV.hidden = YES;
//        self.voiceV.hidden = YES;
//        self.videoV.hidden = YES;
    }
    
    [self.voiceBtn setImage:[UIImage imageNamed:@"play-voice-icon-2"] forState:UIControlStateNormal];
    [self setBtn:self.voiceBtn play:self.topic.top_cmt.voicePlaying];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.topic.top_cmt.voiceuri]];
        top_cmt_player_ = [AVPlayer playerWithPlayerItem:self.playerItem];
    });
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.voiceBtnTopConstraint.constant = (self.voiceBtn.hidden ?
    (self.topic.commentVH >= 45 ? self.topic.commentVH - 45 : 0):
    (self.topic.commentVH >= 45 ? self.topic.commentVH - 45 : 5)) + 1;
    
    self.leftConstraint.constant = self.topic.commentBtnX + Margin;
    
    if (self.topic.type == TGTopicTypePicture) { // 图片
        self.picV.frame = self.topic.middleFrame;
    } else if (self.topic.type == TGTopicTypeVoice) { // 声音
        self.voiceV.frame = self.topic.middleFrame;
    } else if (self.topic.type == TGTopicTypeVideo) { // 视频
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

- (IBAction)play:(UIButton *)playBtn {
    playBtn.selected = !playBtn.isSelected;
    lastPlayBtn_.selected = !lastPlayBtn_.isSelected;
    if (lastCommentM_ != self.topic.top_cmt) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
        
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.topic.top_cmt.voiceuri]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.playerItem];
        
        [top_cmt_player_ replaceCurrentItemWithPlayerItem:self.playerItem];
        [top_cmt_player_ play];
        lastCommentM_.voicePlaying = NO;
        self.topic.top_cmt.voicePlaying = YES;
        [self setBtn:lastPlayBtn_ play:lastCommentM_.voicePlaying];
        [self setBtn:playBtn play:self.topic.top_cmt.voicePlaying];
    }else{
        if(lastCommentM_.voicePlaying){
            [top_cmt_player_ pause];
            self.topic.top_cmt.voicePlaying = NO;
            [self setBtn:playBtn play:self.topic.top_cmt.voicePlaying];
        }else{
            [top_cmt_player_ play];
            self.topic.top_cmt.voicePlaying = YES;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:self.playerItem];
            [self setBtn:playBtn play:self.topic.top_cmt.voicePlaying];
        }
    }
    lastCommentM_ = self.topic.top_cmt;
    lastPlayBtn_ = playBtn;
}

-(void) setBtn : (UIButton *) btn play:(BOOL) isPlay{
    !(!isPlay && [btn.imageView isAnimating]) ? : [btn.imageView stopAnimating];
    !(isPlay && (! btn.imageView.isAnimating)) ? : [btn.imageView startAnimating];
}

-(void) playerItemDidReachEnd:(AVPlayerItem *)playerItem{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    lastCommentM_.voicePlaying = NO;
    self.topic.top_cmt.voicePlaying = NO;
    [self setBtn:self.voiceBtn play:self.topic.top_cmt.voicePlaying];
    [self setBtn:lastPlayBtn_ play:lastCommentM_.voicePlaying];
    [top_cmt_player_ seekToTime:kCMTimeZero];
}

-(void)dealloc{
    [top_cmt_player_ pause];
    lastCommentM_.voicePlaying = NO;
    [self setBtn:lastPlayBtn_ play:lastCommentM_.voicePlaying];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (IBAction)more:(id)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
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

@end
