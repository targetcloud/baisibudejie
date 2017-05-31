//
//  TGCommentNewCell.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/31.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGCommentNewCell.h"
#import "TGUserNewM.h"
#import "TGCommentNewM.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface TGCommentNewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageV;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *commentLbl;
@property (weak, nonatomic) IBOutlet UIImageView *sexImageV;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIButton *hateBtn;
@property (weak, nonatomic) IBOutlet UIButton *voiceBtn;
@property (weak, nonatomic) IBOutlet UILabel *totalLikeCountLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@end

static AVPlayer * commentVoicePlayer_;
static UIButton *lastBtn_;
static TGCommentNewM *lastCommentM_;

@implementation TGCommentNewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    //self.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mainCellBackground"]];
    [self.hateBtn setTitle:@"" forState:UIControlStateNormal];
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setComment:(TGCommentNewM *)comment{
    _comment = comment;
    [self.iconImageV tg_setHeader:comment.user.profile_image];
    self.nameLbl.text = comment.user.username;
    self.commentLbl.text = comment.content;
    [self.likeBtn setTitle: [NSString stringWithFormat:@"%zd",comment.like_count]  forState:UIControlStateNormal];
    [self.hateBtn setTitle: [NSString stringWithFormat:@"%zd",comment.hate_count]  forState:UIControlStateNormal];
    self.sexImageV.image = [UIImage imageNamed:[comment.user.sex isEqualToString:Boy] ? @"Profile_manIcon" : @"Profile_womanIcon"];
    self.voiceBtn.hidden = comment.voiceuri.length<=0;
    self.timeLbl.text = comment.ctime;
    
    if (comment.user.total_cmt_like_count >= 1000) {
        self.totalLikeCountLbl.text = [NSString stringWithFormat:@"%.1fk", comment.user.total_cmt_like_count / 1000.0];
        self.totalLikeCountLbl.backgroundColor = comment.user.total_cmt_like_count >= 10000 ? TGColor(250, 195, 198) : TGColor(212, 205, 214);
    } else {
        self.totalLikeCountLbl.text = [NSString stringWithFormat:@"%zd", comment.user.total_cmt_like_count];
        self.totalLikeCountLbl.backgroundColor = TGColor(191, 205, 224);
    }
    
    if (comment.voiceuri.length) {
        [self.voiceBtn setTitle:[NSString stringWithFormat:@"%zd''", comment.voicetime] forState:UIControlStateNormal];
    }
    
    [self.voiceBtn setImage:[UIImage imageNamed:@"play-voice-icon-2"] forState:UIControlStateNormal];
    [self setBtn:self.voiceBtn play:comment.voicePlaying];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:comment.voiceuri]];
        commentVoicePlayer_ = [AVPlayer playerWithPlayerItem:self.playerItem];
    });
}

- (void)setFrame:(CGRect)frame{
    //frame.size.height += 1;//frame.size.height -= 1 不采用背景图做为分隔,直接在cell里加一个0.5高度的view作为分隔线
    [super setFrame:frame];
}

- (IBAction)voicePlay:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    lastBtn_.selected = !lastBtn_.isSelected;
    if (lastCommentM_ != self.comment) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
        
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.comment.voiceuri]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.playerItem];
        
        [commentVoicePlayer_ replaceCurrentItemWithPlayerItem:self.playerItem];
        [commentVoicePlayer_ play];
        lastCommentM_.voicePlaying = NO;
        self.comment.voicePlaying = YES;
        [self setBtn:lastBtn_ play:lastCommentM_.voicePlaying];
        [self setBtn:sender play:self.comment.voicePlaying];
    }else{
        if(lastCommentM_.voicePlaying){
            [commentVoicePlayer_ pause];
            self.comment.voicePlaying = NO;
            [self setBtn:sender play:self.comment.voicePlaying];
        }else{
            [commentVoicePlayer_ play];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:self.playerItem];
            self.comment.voicePlaying = YES;
            [self setBtn:sender play:self.comment.voicePlaying];
        }
    }
    lastCommentM_ = self.comment;
    lastBtn_ = sender;
}

-(void) setBtn : (UIButton *) btn play:(BOOL) isPlay{
    !(!isPlay && [btn.imageView isAnimating]) ? : [btn.imageView stopAnimating];
    !(isPlay && (! btn.imageView.isAnimating)) ? : [btn.imageView startAnimating];
}

-(void) playerItemDidReachEnd:(AVPlayerItem *)playerItem{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    lastCommentM_.voicePlaying = NO;
    self.comment.voicePlaying = NO;
    [self setBtn:self.voiceBtn play:self.comment.voicePlaying];
    [self setBtn:lastBtn_ play:lastCommentM_.voicePlaying];
    [commentVoicePlayer_ seekToTime:kCMTimeZero];
}

-(void)dealloc{
    [commentVoicePlayer_ pause];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return NO;
}

@end
