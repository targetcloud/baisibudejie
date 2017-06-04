//
//  TGTopCommentCell.m
//  baisibudejie
//
//  Created by targetcloud on 2017/6/4.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGTopCommentCell.h"
#import "TGUserNewM.h"
#import "TGCommentNewM.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface TGTopCommentCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageV;
@property (weak, nonatomic) IBOutlet UILabel *commentLbl;
@property (weak, nonatomic) IBOutlet UIButton *voiceBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceBtnLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentLblCenterYConstratint;

@property (strong, nonatomic) AVPlayerItem *playerItem;
@end

static AVPlayer * commentPlayer_;
static UIButton *lastBtn_;
static TGCommentNewM *lastCommentM_;

@implementation TGTopCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
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

-(void)setCommentM:(TGCommentNewM *)commentM{
    _commentM = commentM;
    [self.iconImageV tg_setHeader:commentM.u.header.length>0 ? commentM.u.header : commentM.user.profile_image.length>0 ? commentM.user.profile_image : commentM.u.profile_image];
    self.commentLbl.attributedText = commentM.attrStrM;
    self.voiceBtn.hidden = commentM.voiceuri.length<=0;
    self.voiceBtnLeftConstraint.constant = commentM.topCommentWidth;
    self.commentLblCenterYConstratint.constant = commentM.topCommentCellHeight > 30 ? 4 : 0;
    if (commentM.voiceuri.length) {
        [self.voiceBtn setTitle:[NSString stringWithFormat:@"%zd''", commentM.voicetime] forState:UIControlStateNormal];
    }
    
    [self.voiceBtn setImage:[UIImage imageNamed:@"play-voice-icon-2"] forState:UIControlStateNormal];
    [self setBtn:self.voiceBtn play:commentM.voicePlaying];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:commentM.voiceuri]];
        commentPlayer_ = [AVPlayer playerWithPlayerItem:self.playerItem];
        commentPlayer_.volume = 1.0f;
    });
}

- (IBAction)voicePlay:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    lastBtn_.selected = !lastBtn_.isSelected;
    if (lastCommentM_ != self.commentM) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
        
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.commentM.voiceuri]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.playerItem];
        
        [commentPlayer_ replaceCurrentItemWithPlayerItem:self.playerItem];
        [commentPlayer_ play];
        lastCommentM_.voicePlaying = NO;
        self.commentM.voicePlaying = YES;
        [self setBtn:lastBtn_ play:lastCommentM_.voicePlaying];
        [self setBtn:sender play:self.commentM.voicePlaying];
    }else{
        if(lastCommentM_.voicePlaying){
            [commentPlayer_ pause];
            self.commentM.voicePlaying = NO;
            [self setBtn:sender play:self.commentM.voicePlaying];
        }else{
            [commentPlayer_ play];
            lastCommentM_.voicePlaying = NO;
            [self setBtn:lastBtn_ play:lastCommentM_.voicePlaying];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:self.playerItem];
            self.commentM.voicePlaying = YES;
            [self setBtn:sender play:self.commentM.voicePlaying];
        }
    }
    lastCommentM_ = self.commentM;
    lastBtn_ = sender;
}

-(void) setBtn : (UIButton *) btn play:(BOOL) isPlay{
    !(!isPlay && [btn.imageView isAnimating]) ? : [btn.imageView stopAnimating];
    !(isPlay && (! btn.imageView.isAnimating)) ? : [btn.imageView startAnimating];
}

-(void) playerItemDidReachEnd:(AVPlayerItem *)playerItem{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    lastCommentM_.voicePlaying = NO;
    self.commentM.voicePlaying = NO;
    [self setBtn:self.voiceBtn play:self.commentM.voicePlaying];
    [self setBtn:lastBtn_ play:lastCommentM_.voicePlaying];
    [commentPlayer_ pause];
    [commentPlayer_ seekToTime:kCMTimeZero];
}

-(void)dealloc{
    [commentPlayer_ pause];
    lastCommentM_.voicePlaying = NO;
    [self setBtn:lastBtn_ play:lastCommentM_.voicePlaying];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    //[avTimer_ invalidate];
    //avTimer_= nil;
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return NO;
}

@end
