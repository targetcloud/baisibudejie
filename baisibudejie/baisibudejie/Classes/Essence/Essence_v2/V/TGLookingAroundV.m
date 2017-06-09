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

@interface TGLookingAroundV()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageV;
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UILabel *playcountLbl;
@property (weak, nonatomic) IBOutlet UILabel *voicetimeLbl;
@end

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
    [self.profileImageV tg_setHeader:topic.u.header borderWidth:1 borderColor:nil];
    [self.imageV tg_setOriginImage:topic.image thumbnailImage:nil placeholder:nil progress:nil completed:nil];
    
    if (topic.audio_playcount >= 10000) {
        self.playcountLbl.text = [NSString stringWithFormat:@"%.1f万播放", topic.audio_playcount / 10000.0];
    } else {
        self.playcountLbl.text = [NSString stringWithFormat:@"%zd播放", topic.audio_playcount];
    }
    
    self.voicetimeLbl.text = [NSString stringWithFormat:@"%02zd:%02zd", topic.audio_duration / 60, topic.audio_duration % 60];
}

@end
