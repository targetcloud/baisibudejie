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
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *playDurationLbl;

@property (strong, nonatomic) AVPlayerItem *playerItem;
@end

static AVPlayer * commentPlayer_;
static AVPlayerLayer *playerLayer_;
static UIButton *lastBtn_;//用于音频
static UIButton *lastPlayBtn_;//用于视频
static TGCommentNewM *lastCommentM_;
static NSTimer *avTimer_;
static UIProgressView *progress_;

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
    
    self.imageV.userInteractionEnabled = YES;
    [self.imageV addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoPlay)] ];
}

-(void) videoPlay{
    if (self.playBtn.isHidden) return;
    [self videoPlay:self.playBtn];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setCommentM:(TGCommentNewM *)commentM{
    _commentM = commentM;
    [self.iconImageV tg_setHeader:commentM.user.profile_image];
    self.nameLbl.text = commentM.user.username;
    self.commentLbl.text = commentM.content;
    [self.likeBtn setTitle: [NSString stringWithFormat:@"%zd",commentM.like_count]  forState:UIControlStateNormal];
    [self.hateBtn setTitle: [NSString stringWithFormat:@"%zd",commentM.hate_count]  forState:UIControlStateNormal];
    self.sexImageV.image = [UIImage imageNamed:[commentM.user.sex isEqualToString:Boy] ? @"Profile_manIcon" : @"Profile_womanIcon"];
    self.voiceBtn.hidden = commentM.voiceuri.length<=0;
    self.playBtn.hidden = commentM.videouri.length<=0;
    self.playDurationLbl.hidden = commentM.videouri.length<=0;
    self.imageV.hidden = commentM.image.length<=0 && commentM.videouri.length<=0;
    self.timeLbl.text = commentM.ctime;
    
    if (commentM.user.total_cmt_like_count >= 1000) {
        self.totalLikeCountLbl.text = [NSString stringWithFormat:@"%.1fk", commentM.user.total_cmt_like_count / 1000.0];
        self.totalLikeCountLbl.backgroundColor = commentM.user.total_cmt_like_count >= 10000 ? TGColor(250, 195, 198) : TGColor(212, 205, 214);
    } else {
        self.totalLikeCountLbl.text = [NSString stringWithFormat:@"%zd", commentM.user.total_cmt_like_count];
        self.totalLikeCountLbl.backgroundColor = TGColor(191, 205, 224);
    }
    
    if (commentM.voiceuri.length) {
        [self.voiceBtn setTitle:[NSString stringWithFormat:@"%zd''", commentM.voicetime] forState:UIControlStateNormal];
        self.commentLbl.text = @"";
        self.voiceBtn.frame = commentM.middleFrame;
    }else if (commentM.image.length>0){
        self.imageV.contentMode = UIViewContentModeScaleAspectFit;
        self.commentLbl.text = @"";
        self.imageV.frame = commentM.middleFrame;
        [self.imageV tg_setOriginImage:commentM.image thumbnailImage:nil placeholder:nil progress:nil completed:nil];
    }else if (commentM.videouri.length>0){
        self.imageV.contentMode = UIViewContentModeScaleAspectFit;
        self.commentLbl.text = @"";
        self.imageV.frame = commentM.middleFrame;
        self.playDurationLbl.text = [NSString stringWithFormat:@"%zd''", commentM.videotime];
        [self.imageV tg_setOriginImage:commentM.video_thumbnail thumbnailImage:nil placeholder:nil progress:nil completed:nil];
    }
    
    [self.voiceBtn setImage:[UIImage imageNamed:@"play-voice-icon-2"] forState:UIControlStateNormal];
    [self setBtn:self.voiceBtn play:commentM.voicePlaying];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:commentM.voiceuri]];
        commentPlayer_ = [AVPlayer playerWithPlayerItem:self.playerItem];
        commentPlayer_.volume = 1.0f;
        playerLayer_ = [AVPlayerLayer playerLayerWithPlayer:commentPlayer_];
        playerLayer_.backgroundColor = [UIColor clearColor].CGColor;
        playerLayer_.videoGravity = AVLayerVideoGravityResizeAspect;
        avTimer_ = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timer) userInfo:nil repeats:YES];
        [avTimer_ setFireDate:[NSDate distantFuture]];
        progress_ = [[UIProgressView alloc] initWithFrame:CGRectZero];
        progress_.backgroundColor = [UIColor whiteColor];
        progress_.tintColor = [UIColor whiteColor];
        progress_.trackTintColor =[UIColor whiteColor];
        progress_.progressTintColor = [UIColor redColor];
    });
    self.commentM.videoPlaying = NO;
    lastCommentM_.videoPlaying = NO;
    [self.playBtn setImage:[UIImage imageNamed:@"video-play"] forState:UIControlStateNormal];
    [lastPlayBtn_  setImage:[UIImage imageNamed:@"video-play"] forState:UIControlStateNormal];
    
    //如果是声音则不停，如果是视频则停
    lastBtn_ && lastCommentM_.voicePlaying ? :[commentPlayer_ pause];
    
    [avTimer_ setFireDate:[NSDate distantFuture]];
    [playerLayer_ removeFromSuperlayer];
    progress_.hidden = !self.commentM.videoPlaying;
    progress_.progress = 0;
}

- (void)timer{
    //TGLog(@" --- progress --- ")
    Float64 currentTime = CMTimeGetSeconds(commentPlayer_.currentItem.currentTime);
    if (currentTime > 0){
        progress_.progress =  currentTime / CMTimeGetSeconds(commentPlayer_.currentItem.duration);
        TGLog(@" --- progress %f --- ",progress_.progress)
    }
}

- (void)setFrame:(CGRect)frame{
    //frame.size.height += 1;//frame.size.height -= 1 不采用背景图做为分隔,直接在cell里加一个0.5高度的view作为分隔线
    [super setFrame:frame];
}

- (IBAction)voicePlay:(UIButton *)sender {
    progress_.hidden = YES;
    [avTimer_ setFireDate:[NSDate distantFuture]];
    lastCommentM_.videoPlaying = NO;
    [lastPlayBtn_ setImage:[UIImage imageNamed:@"video-play"] forState:UIControlStateNormal];
    
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

- (IBAction)videoPlay:(UIButton *)playBtn {
    lastCommentM_.voicePlaying = NO;
    [self setBtn:lastBtn_ play:lastCommentM_.voicePlaying];
    
    playBtn.selected = !playBtn.isSelected;
    lastPlayBtn_.selected = !lastPlayBtn_.isSelected;
    if (lastCommentM_ != self.commentM) {
        [playerLayer_ removeFromSuperlayer];
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.commentM.videouri]];
        [commentPlayer_ replaceCurrentItemWithPlayerItem:self.playerItem];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.playerItem];
        
        playerLayer_.frame = CGRectMake(self.imageV.x, self.imageV.y, self.imageV.width, self.imageV.height);
        progress_.frame = CGRectMake(playerLayer_.frame.origin.x, CGRectGetMaxY(playerLayer_.frame), playerLayer_.frame.size.width, 2);
        [self.layer addSublayer:playerLayer_];
        [self addSubview:progress_];
        progress_.progress = 0;
        [commentPlayer_ play];
        [avTimer_ setFireDate:[NSDate date]];
        lastCommentM_.videoPlaying = NO;
        self.commentM.videoPlaying = YES;
        [lastPlayBtn_ setImage:[UIImage imageNamed:@"video-play"] forState:UIControlStateNormal];
        [playBtn setImage:[UIImage imageNamed:@"playButtonPause"] forState:UIControlStateNormal];
    }else{
        if(lastCommentM_.videoPlaying){
            [commentPlayer_ pause];
            [avTimer_ setFireDate:[NSDate distantFuture]];
            self.commentM.videoPlaying = NO;
            [playBtn setImage:[UIImage imageNamed:@"video-play"] forState:UIControlStateNormal];
        }else{
            playerLayer_.frame = CGRectMake(self.imageV.x, self.imageV.y, self.imageV.width, self.imageV.height);
            progress_.frame = CGRectMake(playerLayer_.frame.origin.x, CGRectGetMaxY(playerLayer_.frame), playerLayer_.frame.size.width, 2);
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:self.playerItem];
            [self.layer addSublayer:playerLayer_];
            [self addSubview:progress_];
            [commentPlayer_ play];
            [avTimer_ setFireDate:[NSDate date]];
            self.commentM.videoPlaying = YES;
            [playBtn setImage:[UIImage imageNamed:@"playButtonPause"] forState:UIControlStateNormal];
        }
    }
    progress_.hidden = !self.commentM.videoPlaying;
    lastCommentM_ = self.commentM;
    lastPlayBtn_ = playBtn;
    //TGLog(@"%zd %@ %@",progress_.hidden,NSStringFromCGRect(playerLayer_.frame),NSStringFromCGRect(progress_.frame));
}

-(void) setBtn : (UIButton *) btn play:(BOOL) isPlay{
    !(!isPlay && [btn.imageView isAnimating]) ? : [btn.imageView stopAnimating];
    !(isPlay && (! btn.imageView.isAnimating)) ? : [btn.imageView startAnimating];
}

-(void) playerItemDidReachEnd:(AVPlayerItem *)playerItem{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    lastCommentM_.voicePlaying = NO;
    self.commentM.voicePlaying = NO;
    lastCommentM_.videoPlaying = NO;
    self.commentM.videoPlaying = NO;
    [lastPlayBtn_ setImage:[UIImage imageNamed:@"video-play"] forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:@"video-play"] forState:UIControlStateNormal];
    [self setBtn:self.voiceBtn play:self.commentM.voicePlaying];
    [self setBtn:lastBtn_ play:lastCommentM_.voicePlaying];
    [commentPlayer_ pause];
    [commentPlayer_ seekToTime:kCMTimeZero];
    [playerLayer_ removeFromSuperlayer];
    progress_.hidden = !self.commentM.videoPlaying;
    progress_.progress = 0;
}

-(void)dealloc{
    [commentPlayer_ pause];
    [playerLayer_ removeFromSuperlayer];
    lastCommentM_.voicePlaying = NO;
    lastCommentM_.videoPlaying = NO;
    [self setBtn:lastBtn_ play:lastCommentM_.voicePlaying];
    [lastPlayBtn_ setImage:[UIImage imageNamed:@"video-play"] forState:UIControlStateNormal];
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
