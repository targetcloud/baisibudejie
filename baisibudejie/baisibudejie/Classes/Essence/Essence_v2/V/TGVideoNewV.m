//
//  TGVideoNewV.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/30.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGVideoNewV.h"
#import "TGTopicNewM.h"
#import <UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>

@interface TGVideoNewV()
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UILabel *playcountLbl;
@property (weak, nonatomic) IBOutlet UILabel *videotimeLbl;
@property (weak, nonatomic) IBOutlet UIImageView *placeholderV;
@property (weak, nonatomic) IBOutlet UIButton *videoPlayBtn;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@end

static AVPlayer * video_player_;
static AVPlayerLayer *playerLayer_;
static UIButton *lastPlayBtn_;
static TGTopicNewM *lastTopicM_;
static NSTimer *avTimer_;
static UIProgressView *progress_;

@implementation TGVideoNewV

- (void)awakeFromNib{
    [super awakeFromNib];
    self.autoresizingMask = UIViewAutoresizingNone;
    self.imageV.userInteractionEnabled = YES;
    [self.imageV addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(seeBigPic)] ];
}

-(void) seeBigPic{
    [self play:self.videoPlayBtn];
}

- (void)setTopic:(TGTopicNewM *)topic{
    _topic = topic;
    
    self.placeholderV.hidden = NO;
    [self.imageV tg_setOriginImage:topic.image thumbnailImage:topic.video_thumbnail_small placeholder:nil  progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image) return;
        self.placeholderV.hidden = YES;
    }];
    
    if (topic.video_playcount >= 10000) {
        self.playcountLbl.text = [NSString stringWithFormat:@"%.1f万播放", topic.video_playcount / 10000.0];
    } else {
        self.playcountLbl.text = [NSString stringWithFormat:@"%zd播放", topic.video_playcount];
    }
    
    self.videotimeLbl.text = [NSString stringWithFormat:@"%02zd:%02zd", topic.video_duration / 60, topic.video_duration % 60];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.topic.video_uri]];
        video_player_ = [AVPlayer playerWithPlayerItem:self.playerItem];
        video_player_.volume = 1.0f;
        playerLayer_ = [AVPlayerLayer playerLayerWithPlayer:video_player_];
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
    self.topic.videoPlaying = NO;
    lastTopicM_.videoPlaying = NO;
    [self.videoPlayBtn setImage:[UIImage imageNamed:@"video-play"] forState:UIControlStateNormal];
    [lastPlayBtn_  setImage:[UIImage imageNamed:@"video-play"] forState:UIControlStateNormal];
    [video_player_ pause];//可以继续播放 else else else
    [avTimer_ setFireDate:[NSDate distantFuture]];
    [playerLayer_ removeFromSuperlayer];
    progress_.hidden = !self.topic.videoPlaying;
    progress_.progress = 0;
}

- (void)timer{
    //TGLog(@" --- progress --- ")
    Float64 currentTime = CMTimeGetSeconds(video_player_.currentItem.currentTime);
    if (currentTime > 0){
        progress_.progress =  currentTime / CMTimeGetSeconds(video_player_.currentItem.duration);
        TGLog(@" --- progress %f --- ",progress_.progress)
    }
}

- (IBAction)play:(UIButton *)playBtn {
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    if ([systemVersion integerValue] < 9) {
        MPMoviePlayerViewController *movieVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:self.topic.video_uri]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentMoviePlayerViewControllerAnimated:movieVC];
    }else{
        playBtn.selected = !playBtn.isSelected;
        lastPlayBtn_.selected = !lastPlayBtn_.isSelected;
        if (lastTopicM_ != self.topic) {
            [playerLayer_ removeFromSuperlayer];
            self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.topic.video_uri]];
            [video_player_ replaceCurrentItemWithPlayerItem:self.playerItem];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:self.playerItem];
            
            playerLayer_.frame = CGRectMake(self.imageV.x, self.imageV.y, self.imageV.width, self.imageV.height);
            progress_.frame = CGRectMake(playerLayer_.frame.origin.x, CGRectGetMaxY(playerLayer_.frame), playerLayer_.frame.size.width, 2);
            [self.layer addSublayer:playerLayer_];
            [self addSubview:progress_];
            progress_.progress = 0;
            [video_player_ play];
            [avTimer_ setFireDate:[NSDate date]];
            lastTopicM_.videoPlaying = NO;
            self.topic.videoPlaying = YES;
            [lastPlayBtn_ setImage:[UIImage imageNamed:@"video-play"] forState:UIControlStateNormal];
            [playBtn setImage:[UIImage imageNamed:@"playButtonPause"] forState:UIControlStateNormal];
        }else{
            if(lastTopicM_.videoPlaying){
                [video_player_ pause];
                [avTimer_ setFireDate:[NSDate distantFuture]];
                self.topic.videoPlaying = NO;
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
                [video_player_ play];
                [avTimer_ setFireDate:[NSDate date]];
                self.topic.videoPlaying = YES;
                [playBtn setImage:[UIImage imageNamed:@"playButtonPause"] forState:UIControlStateNormal];
            }
        }
        progress_.hidden = !self.topic.videoPlaying;
        lastTopicM_ = self.topic;
        lastPlayBtn_ = playBtn;
    }
}

-(void) playerItemDidReachEnd:(AVPlayerItem *)playerItem{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    lastTopicM_.videoPlaying = NO;
    self.topic.videoPlaying = NO;
    [lastPlayBtn_ setImage:[UIImage imageNamed:@"video-play"] forState:UIControlStateNormal];
    [self.videoPlayBtn setImage:[UIImage imageNamed:@"video-play"] forState:UIControlStateNormal];
    [video_player_ pause];
    [video_player_ seekToTime:kCMTimeZero];
    [playerLayer_ removeFromSuperlayer];
    progress_.hidden = !self.topic.videoPlaying;
    progress_.progress = 0;
}

-(void)dealloc{
    [video_player_ pause];
    [playerLayer_ removeFromSuperlayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    //[avTimer_ invalidate];
    //avTimer_= nil;
}


@end
