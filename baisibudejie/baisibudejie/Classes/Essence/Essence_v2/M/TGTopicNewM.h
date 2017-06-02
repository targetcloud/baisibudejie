//
//  TGTopicNewM.h
//  baisibudejie
//
//  Created by targetcloud on 2017/5/30.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TGUserNewM;
@class TGCommentNewM;
@interface TGTopicNewM : NSObject
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *type;//audio image video gif text
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) NSInteger up;
@property (nonatomic, assign) NSInteger down;
@property (nonatomic, assign) NSInteger forward;
@property (nonatomic, assign) NSInteger comment;
@property (nonatomic, copy) NSString *share_url;
@property (nonatomic, copy) NSString *passtime;
@property (nonatomic, assign) NSInteger bookmark;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) TGUserNewM *u;

@property (nonatomic, assign) NSInteger video_playfcount;
@property (nonatomic, assign) NSInteger video_width;
@property (nonatomic, assign) NSInteger video_height;
@property (nonatomic, copy) NSString *video_uri;
@property (nonatomic, assign) NSInteger video_duration;
@property (nonatomic, assign) NSInteger  video_playcount;
@property (nonatomic, copy) NSString * video_thumbnail;
@property (nonatomic, copy) NSString * video_thumbnail_small;

@property (nonatomic, strong) NSArray<TGCommentNewM *> *top_comments;

@property (nonatomic, copy) NSString * image_medium;
@property (nonatomic, copy) NSString * image_big;
@property (nonatomic, assign) NSInteger image_height;
@property (nonatomic, assign) NSInteger image_width;
@property (nonatomic, copy) NSString * image_small;
@property (nonatomic, copy) NSString * image_thumbnail_small;

@property (nonatomic, copy) NSString * images_gif;
@property (nonatomic, assign) NSInteger gif_width;
@property (nonatomic, copy) NSString * gif_thumbnail;
@property (nonatomic, assign) NSInteger gif_height;

@property (nonatomic, assign) NSInteger audio_playfcount;
@property (nonatomic, assign) NSInteger audio_height;
@property (nonatomic, assign) NSInteger audio_width;
@property (nonatomic, assign) NSInteger audio_duration;
@property (nonatomic, assign) NSInteger audio_playcount;
@property (nonatomic, copy) NSString * audio_uri;
@property (nonatomic, copy) NSString * audio_thumbnail;
@property (nonatomic, copy) NSString * audio_thumbnail_small;

@property (nonatomic, assign,readonly) NSInteger width;
@property (nonatomic, assign,readonly) NSInteger height;
@property (nonatomic, copy,readonly) NSString * image;

@property (nonatomic, assign,readonly) CGFloat cellHeight;
@property (nonatomic, assign,readonly) CGFloat middleY;
@property (nonatomic, assign,readonly) CGFloat defaultHeight;//用于收缩展开

@property (nonatomic, assign,readonly) CGFloat textHeight;
@property (nonatomic, assign) CGRect middleFrame;
@property (nonatomic, assign, getter=isBigPicture) BOOL bigPicture;

@property (nonatomic, assign, getter=isShowAllWithoutComment) BOOL showAllWithoutComment;//用于评论VC
@property (nonatomic, assign,readonly) CGFloat cellHeightWithoutComment;//用于评论VC

@property (nonatomic, assign) CGFloat picProgress;
@property (nonatomic, assign,getter=is_voicePlaying) BOOL voicePlaying;
@property (nonatomic, assign,getter=is_videoPlaying) BOOL videoPlaying;
@property (nonatomic, assign,readonly) CGFloat commentVH;
@property (nonatomic, copy,readonly) NSMutableAttributedString * attrStrM;
@end
