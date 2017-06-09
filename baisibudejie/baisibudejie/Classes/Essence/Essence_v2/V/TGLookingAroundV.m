//
//  TGLookingAroundV.m
//  baisibudejie
//
//  Created by targetcloud on 2017/6/9.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGLookingAroundV.h"
#import "TGTopicNewM.h"
#import "TGUserNewM.h"
#import <AVFoundation/AVFoundation.h>
#import <DALabeledCircularProgressView.h>

@interface TGLookingAroundV()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageV;
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UILabel *playcountLbl;
@property (weak, nonatomic) IBOutlet UILabel *voicetimeLbl;
@property (weak, nonatomic) IBOutlet UIButton *voicePlayBtn;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@end

static AVPlayer * walkman_;
static UIButton *lastPlayBtn_;
static TGTopicNewM *lastTopicM_;
static NSTimer *avTimer_;
static DALabeledCircularProgressView  *progressV_;
static CGFloat const progressTrackW = 3;

@implementation TGLookingAroundV

- (void)awakeFromNib{
    [super awakeFromNib];
    self.autoresizingMask = UIViewAutoresizingNone;
    self.imageV.userInteractionEnabled = YES;
    [self.imageV addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetail)] ];
}

-(void) showDetail {
    !_commentBlock ? : _commentBlock(self.topic.ID);
}

- (void)setTopic:(TGTopicNewM *)topic{
    _topic = topic;
    
    if (lastTopicM_ && ![_topic.ID isEqualToString:lastTopicM_.ID]){
        progressV_.hidden = YES;
        [progressV_ removeFromSuperview];
    }
    
    [self.profileImageV tg_setHeader:topic.u.header borderWidth:1 borderColor:nil];
    [self.imageV tg_setOriginImage:topic.image thumbnailImage:nil placeholder:nil progress:nil completed:nil];
    
    if (topic.audio_playcount >= 10000) {
        self.playcountLbl.text = [NSString stringWithFormat:@"%.1f万播放", topic.audio_playcount / 10000.0];
    } else {
        self.playcountLbl.text = [NSString stringWithFormat:@"%zd播放", topic.audio_playcount];
    }
    
    self.voicetimeLbl.text = [NSString stringWithFormat:@"%02zd:%02zd", topic.audio_duration / 60, topic.audio_duration % 60];
    
    [self.voicePlayBtn setImage:[UIImage imageNamed:topic.voicePlaying ? @"btn_player_pause":@"playButtonPlay"] forState:UIControlStateNormal];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.topic.audio_uri]];
        walkman_ = [AVPlayer playerWithPlayerItem:self.playerItem];
        avTimer_ = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timer) userInfo:nil repeats:YES];
        [avTimer_ setFireDate:[NSDate distantFuture]];
        
        progressV_ = [[DALabeledCircularProgressView alloc] initWithFrame:CGRectZero];
        progressV_.roundedCorners = YES;
        progressV_.progressLabel.textColor = [UIColor redColor];
        progressV_.trackTintColor = [UIColor whiteColor];
        progressV_.progressTintColor = [UIColor redColor];
        progressV_.hidden = YES;
        progressV_.progressLabel.text = @"";
        progressV_.thicknessRatio = 0.1;
        [progressV_ setProgress:0 animated:NO];
        
    });
    if (topic.voicePlaying){
        [self insertSubview:progressV_ belowSubview:self.voicePlayBtn];
        progressV_.hidden = !topic.voicePlaying;
    }
}

-(void) layoutSubviews{
    [super layoutSubviews];
    progressV_.frame = CGRectMake(lastPlayBtn_.frame.origin.x-progressTrackW, lastPlayBtn_.frame.origin.y-progressTrackW, lastPlayBtn_.frame.size.width+2*progressTrackW, lastPlayBtn_.frame.size.height+2*progressTrackW);
}

- (void)timer{
    //TGLog(@" --- progress --- ")
    Float64 currentTime = CMTimeGetSeconds(walkman_.currentItem.currentTime);
    if (currentTime > 0){
        progressV_.hidden = NO;
        [progressV_ setProgress:currentTime / CMTimeGetSeconds(walkman_.currentItem.duration) animated:YES];
        //[progressV_.progressLabel setText:[NSString stringWithFormat:@"%.0f%%",progressV_.progress * 100]];
        TGLog(@" --- progress %f --- ",progressV_.progress)
    }
}

- (IBAction)play:(UIButton *)playBtn {
    playBtn.selected = !playBtn.isSelected;
    lastPlayBtn_.selected = !lastPlayBtn_.isSelected;
    if (lastTopicM_ != self.topic) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
        
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.topic.audio_uri]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.playerItem];
        [walkman_ replaceCurrentItemWithPlayerItem:self.playerItem];
        
        progressV_.frame = CGRectMake(playBtn.frame.origin.x-2, playBtn.frame.origin.y-2, playBtn.frame.size.width+4, playBtn.frame.size.height+4);
        [self insertSubview:progressV_ belowSubview:self.voicePlayBtn];
        [progressV_ setProgress:0 animated:NO];
        
        [walkman_ play];
        [avTimer_ setFireDate:[NSDate date]];
        lastTopicM_.voicePlaying = NO;
        self.topic.voicePlaying = YES;
        [lastPlayBtn_ setImage:[UIImage imageNamed:@"playButtonPlay"] forState:UIControlStateNormal];
        [playBtn setImage:[UIImage imageNamed:@"btn_player_pause"] forState:UIControlStateNormal];
    }else{
        if(lastTopicM_.voicePlaying){
            [walkman_ pause];
            [avTimer_ setFireDate:[NSDate distantFuture]];
            self.topic.voicePlaying = NO;
            [playBtn setImage:[UIImage imageNamed:@"playButtonPlay"] forState:UIControlStateNormal];
        }else{
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:self.playerItem];
            progressV_.frame = CGRectMake(playBtn.frame.origin.x-2, playBtn.frame.origin.y-2, playBtn.frame.size.width+4, playBtn.frame.size.height+4);
            [self insertSubview:progressV_ belowSubview:self.voicePlayBtn];
            
            [walkman_ play];
            [avTimer_ setFireDate:[NSDate date]];
            self.topic.voicePlaying = YES;
            [playBtn setImage:[UIImage imageNamed:@"btn_player_pause"] forState:UIControlStateNormal];
        }
    }
    lastTopicM_ = self.topic;
    lastPlayBtn_ = playBtn;
    progressV_.hidden = !self.topic.voicePlaying;
}

-(void) playerItemDidReachEnd:(AVPlayerItem *)playerItem{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    lastTopicM_.voicePlaying = NO;
    self.topic.voicePlaying = NO;
    [lastPlayBtn_ setImage:[UIImage imageNamed:@"playButtonPlay"] forState:UIControlStateNormal];
    [self.voicePlayBtn setImage:[UIImage imageNamed:@"playButtonPlay"] forState:UIControlStateNormal];
    [walkman_ seekToTime:kCMTimeZero];
    [progressV_ setProgress:0 animated:NO];
    [progressV_ removeFromSuperview];
    progressV_.hidden = YES;
}

-(void)dealloc{
    [walkman_ pause];
    lastTopicM_.voicePlaying = NO;
    [lastPlayBtn_ setImage:[UIImage imageNamed:@"playButtonPlay"] forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    //[avTimer_ invalidate];
    //avTimer_= nil;
}

@end
