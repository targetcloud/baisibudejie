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
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@end

static AVPlayer * walkman_;
static UIButton *lastPlayBtn_;
static TGTopicNewM *lastTopicM_;
static UIImageView * lastProfileImageV;
static NSTimer *avTimer_;
static DALabeledCircularProgressView  *progressV_;
static CGFloat const progressTrackW = 2;

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
    
    [self.profileImageV tg_setHeader:topic.u.header borderWidth:progressTrackW borderColor:[UIColor clearColor]];
    [self.imageV tg_setOriginImage:topic.image thumbnailImage:nil placeholder:nil progress:nil completed:nil];
    
    if (topic.audio_playcount >= 10000) {
        self.playcountLbl.text = [NSString stringWithFormat:@"%.1f万播放", topic.audio_playcount / 10000.0];
    } else {
        self.playcountLbl.text = [NSString stringWithFormat:@"%zd播放", topic.audio_playcount];
    }
    
    self.likeBtn.selected = topic.isLikeSelected;
    
    self.voicetimeLbl.text = [NSString stringWithFormat:@"%02zd:%02zd", topic.audio_duration / 60, topic.audio_duration % 60];
    
    [self.voicePlayBtn setImage:[UIImage imageNamed:topic.voicePlaying ? @"walkman_pause":@"playButtonPlay"] forState:UIControlStateNormal];
    topic.voicePlaying ? [self addRotationAnimation] : [self.profileImageV.layer removeAllAnimations];
    if (topic.voicePlaying){
        progressV_.hidden = NO;
        [self.contentView insertSubview:progressV_ belowSubview:self.profileImageV];
        progressV_.frame =CGRectMake(self.profileImageV.frame.origin.x , self.profileImageV.frame.origin.y , self.profileImageV.frame.size.width, self.profileImageV.frame.size.height) ;
    }
    
    for (UIView *tmpView in self.contentView.subviews){
        if([tmpView isMemberOfClass:[DALabeledCircularProgressView class]]){
            tmpView.hidden = !(topic.voicePlaying);
            break;
        }
    }
    
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
}

-(void)addRotationAnimation{
    int direction = 1;  //or -1
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:(2 * M_PI) * direction];
    rotationAnimation.duration = 4.0f;
    rotationAnimation.repeatCount = HUGE_VALF;
    //rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.profileImageV.layer addAnimation:rotationAnimation forKey:@"rotateAnimation"];
}

-(void)removeRotateAnimation{
    [lastProfileImageV.layer removeAllAnimations];
    [self.profileImageV.layer removeAllAnimations];
}

-(void) layoutSubviews{
    [super layoutSubviews];
    TGLog(@"--- %@ --- ",NSStringFromCGRect(progressV_.frame));
}

- (void)timer{
    //TGLog(@" --- progress --- ")
    Float64 currentTime = CMTimeGetSeconds(walkman_.currentItem.currentTime);
    if (currentTime > 0){
        //progressV_.hidden = NO;
        [progressV_ setProgress:currentTime / CMTimeGetSeconds(walkman_.currentItem.duration) animated:YES];
        //[progressV_.progressLabel setText:[NSString stringWithFormat:@"%.0f%%",progressV_.progress * 100]];
        //TGLog(@" --- progress %f --- ",progressV_.progress)
    }
}

-(void)play{
    [self play:self.voicePlayBtn];
}

- (IBAction)play:(UIButton *)playBtn {
    playBtn.selected = !playBtn.isSelected;
    lastPlayBtn_.selected = !lastPlayBtn_.isSelected;
    [progressV_ removeFromSuperview];
    if (lastTopicM_ != self.topic) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
        
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.topic.audio_uri]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.playerItem];
        [walkman_ replaceCurrentItemWithPlayerItem:self.playerItem];
        [self.contentView insertSubview:progressV_ belowSubview:self.profileImageV];
        progressV_.frame =CGRectMake(self.profileImageV.frame.origin.x, self.profileImageV.frame.origin.y, self.profileImageV.frame.size.width, self.profileImageV.frame.size.height) ;
        [progressV_ setProgress:0 animated:NO];
        progressV_.hidden = NO;
        [walkman_ play];
        [self removeRotateAnimation];
        [self addRotationAnimation];
        [avTimer_ setFireDate:[NSDate date]];
        lastTopicM_.voicePlaying = NO;
        self.topic.voicePlaying = YES;
        [lastPlayBtn_ setImage:[UIImage imageNamed:@"playButtonPlay"] forState:UIControlStateNormal];
        [playBtn setImage:[UIImage imageNamed:@"walkman_pause"] forState:UIControlStateNormal];
    }else{
        if(lastTopicM_.voicePlaying){
            [walkman_ pause];
            [self removeRotateAnimation];
            [avTimer_ setFireDate:[NSDate distantFuture]];
            self.topic.voicePlaying = NO;
            [playBtn setImage:[UIImage imageNamed:@"playButtonPlay"] forState:UIControlStateNormal];
        }else{
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:self.playerItem];
            [walkman_ play];
            [self removeRotateAnimation];
            [self addRotationAnimation];
            [avTimer_ setFireDate:[NSDate date]];
            self.topic.voicePlaying = YES;
            [playBtn setImage:[UIImage imageNamed:@"walkman_pause"] forState:UIControlStateNormal];
            progressV_.hidden = NO;
            [self.contentView insertSubview:progressV_ belowSubview:self.profileImageV];
            progressV_.frame =CGRectMake(self.profileImageV.frame.origin.x , self.profileImageV.frame.origin.y , self.profileImageV.frame.size.width, self.profileImageV.frame.size.height) ;
        }
    }
    lastTopicM_ = self.topic;
    lastPlayBtn_ = playBtn;
    lastProfileImageV = self.profileImageV;
}

-(void) replacePlayerItem:(TGTopicNewM *)topic{
    lastTopicM_ = topic;
    lastTopicM_.voicePlaying = YES;
    [walkman_ pause];
    [walkman_ seekToTime:kCMTimeZero];
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:topic.audio_uri]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    [walkman_ replaceCurrentItemWithPlayerItem:self.playerItem];
    [walkman_ play];
}

-(void) playerItemDidReachEnd:(AVPlayerItem *)playerItem{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    lastTopicM_.voicePlaying = NO;
    self.topic.voicePlaying = NO;
    [lastPlayBtn_ setImage:[UIImage imageNamed:@"playButtonPlay"] forState:UIControlStateNormal];
    [self.voicePlayBtn setImage:[UIImage imageNamed:@"playButtonPlay"] forState:UIControlStateNormal];
    [walkman_ pause];
    [walkman_ seekToTime:kCMTimeZero];
    [self removeRotateAnimation];
    [progressV_ setProgress:0 animated:NO];
    [progressV_ removeFromSuperview];
    progressV_.hidden = YES;
    if (lastTopicM_.isLikeSelected){
        if (self.nextBlock) {//循环播放喜欢，喜欢的在界面则动画切到喜欢的cell上，若不在，则直接替换playerItem
            self.nextBlock(lastTopicM_.ID);
            return;
        }
    }
}

- (IBAction)likebtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.topic.likeSelected = sender.selected;
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
