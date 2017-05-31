//
//  TGVoiceV.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/12.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGVoiceV.h"
#import "TGTopicM.h"
#import "TGSeeBigPicVC.h"
#import <UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <DALabeledCircularProgressView.h>

@interface TGVoiceV()
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UILabel *playcountLbl;
@property (weak, nonatomic) IBOutlet UILabel *voicetimeLbl;
@property (weak, nonatomic) IBOutlet UIImageView *placeholderImageV;
@property (weak, nonatomic) IBOutlet UIButton *voicePlayBtn;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@end

static AVPlayer * voice_player_;
static UIButton *lastPlayBtn_;
static TGTopicM *lastTopicM_;
static NSTimer *avTimer_;
static DALabeledCircularProgressView  *progressV_;

@implementation TGVoiceV

- (void)awakeFromNib{
    [super awakeFromNib];
    self.autoresizingMask = UIViewAutoresizingNone;
    self.imageV.userInteractionEnabled = YES;
    [self.imageV addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(seeBigPic)] ];
}

-(void) seeBigPic{
    TGSeeBigPicVC *vc = [[TGSeeBigPicVC alloc] init];
    vc.topic = self.topic;
    //    [self.window.rootViewController presentViewController:vc animated:YES completion:nil];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:vc animated:YES completion:nil];
}

- (void)setTopic:(TGTopicM *)topic{
    _topic = topic;
    if (lastTopicM_ && ![_topic.ID isEqualToString:lastTopicM_.ID]){
        progressV_.hidden = YES;
        [progressV_ removeFromSuperview];
    }
    //沙盒大图 -> WIFI -> 手机网络3G4G（4G大图 3G小图） -> 小图    移至imageView分类去
    /*
     UIImage *placeholder = nil;
     AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    UIImage *originImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:topic.image1];//沙盒会先检查内存
    if (originImage) {
        self.imageV.image = originImage;
    } else {
        if (mgr.isReachableViaWiFi) {
            [self.imageV sd_setImageWithURL:[NSURL URLWithString:topic.image1] placeholderImage:placeholder];
        } else if (mgr.isReachableViaWWAN) {
            BOOL downloadOriginImageWhen3GOr4G = YES;
            if (downloadOriginImageWhen3GOr4G) {
                [self.imageV sd_setImageWithURL:[NSURL URLWithString:topic.image1] placeholderImage:placeholder];
            } else {
                [self.imageV sd_setImageWithURL:[NSURL URLWithString:topic.image0] placeholderImage:placeholder];
            }
        } else {
            UIImage *thumbnailImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:topic.image0];
            if (thumbnailImage) {
                self.imageV.image = thumbnailImage;
            } else {
                self.imageV.image = placeholder;
            }
        }
    }
    */
    self.placeholderImageV.hidden = NO;
    [self.imageV tg_setOriginImage:topic.image1 thumbnailImage:topic.image0 placeholder:nil progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image) return;
        self.placeholderImageV.hidden = YES;
    }];
    //[self.imageV sd_setImageWithURL:[NSURL URLWithString:topic.image1] placeholderImage:placeholder];
    
    if (topic.playcount >= 10000) {
        self.playcountLbl.text = [NSString stringWithFormat:@"%.1f万播放", topic.playcount / 10000.0];
    } else {
        self.playcountLbl.text = [NSString stringWithFormat:@"%zd播放", topic.playcount];
    }
    
    self.voicetimeLbl.text = [NSString stringWithFormat:@"%02zd:%02zd", topic.voicetime / 60, topic.voicetime % 60];
    
    [self.voicePlayBtn setImage:[UIImage imageNamed:topic.voicePlaying ? @"playButtonPause":@"playButtonPlay"] forState:UIControlStateNormal];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.topic.voiceuri]];
        voice_player_ = [AVPlayer playerWithPlayerItem:self.playerItem];
        avTimer_ = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timer) userInfo:nil repeats:YES];
        //[[NSRunLoop mainRunLoop] addTimer:avTimer_ forMode:NSRunLoopCommonModes];
        [avTimer_ setFireDate:[NSDate distantFuture]];
        
        progressV_ = [[DALabeledCircularProgressView alloc] initWithFrame:CGRectZero];
        progressV_.roundedCorners = YES;
        progressV_.progressLabel.textColor = [UIColor redColor];
        progressV_.trackTintColor = [UIColor clearColor];
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
    progressV_.frame = CGRectMake(lastPlayBtn_.frame.origin.x-2, lastPlayBtn_.frame.origin.y-2, lastPlayBtn_.frame.size.width+4, lastPlayBtn_.frame.size.height+4);
}

- (void)timer{
    //TGLog(@" --- progress --- ")
    Float64 currentTime = CMTimeGetSeconds(voice_player_.currentItem.currentTime);
    if (currentTime > 0){
        progressV_.hidden = NO;
        [progressV_ setProgress:currentTime / CMTimeGetSeconds(voice_player_.currentItem.duration) animated:YES];
        [progressV_.progressLabel setText:[NSString stringWithFormat:@"%.0f%%",progressV_.progress * 100]];
        TGLog(@" --- progress %f --- ",progressV_.progress)
    }
}

- (IBAction)play:(UIButton *)playBtn {
    playBtn.selected = !playBtn.isSelected;
    lastPlayBtn_.selected = !lastPlayBtn_.isSelected;
    if (lastTopicM_ != self.topic) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
        
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.topic.voiceuri]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.playerItem];
        [voice_player_ replaceCurrentItemWithPlayerItem:self.playerItem];
        
        progressV_.frame = CGRectMake(playBtn.frame.origin.x-2, playBtn.frame.origin.y-2, playBtn.frame.size.width+4, playBtn.frame.size.height+4);
        [self insertSubview:progressV_ belowSubview:self.voicePlayBtn];
        [progressV_ setProgress:0 animated:NO];
        
        [voice_player_ play];
        [avTimer_ setFireDate:[NSDate date]];
        lastTopicM_.voicePlaying = NO;
        self.topic.voicePlaying = YES;
        [lastPlayBtn_ setImage:[UIImage imageNamed:@"playButtonPlay"] forState:UIControlStateNormal];
        [playBtn setImage:[UIImage imageNamed:@"playButtonPause"] forState:UIControlStateNormal];
    }else{
        if(lastTopicM_.voicePlaying){
            [voice_player_ pause];
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
            
            [voice_player_ play];
            [avTimer_ setFireDate:[NSDate date]];
            self.topic.voicePlaying = YES;
            [playBtn setImage:[UIImage imageNamed:@"playButtonPause"] forState:UIControlStateNormal];
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
    [voice_player_ seekToTime:kCMTimeZero];
    [progressV_ setProgress:0 animated:NO];
    [progressV_ removeFromSuperview];
    progressV_.hidden = YES;
}

-(void)dealloc{
    [voice_player_ pause];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    //[avTimer_ invalidate];
    //avTimer_= nil;
}

@end
