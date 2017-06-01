//
//  TGCommentNewM.h
//  baisibudejie
//
//  Created by targetcloud on 2017/5/30.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TGUserNewM;

@interface TGCommentNewM : NSObject
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *data_id;
@property (strong , nonatomic)TGUserNewM *u;
@property (strong , nonatomic)TGUserNewM *user;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) NSInteger like_count;
@property (nonatomic, assign) NSInteger hate_count;
@property (nonatomic, assign) NSInteger floor;
@property (nonatomic, copy) NSString *passtime;
@property (nonatomic, copy) NSString *ctime;
@property (nonatomic, assign) NSInteger voicetime;
@property (nonatomic, copy) NSString *voiceuri;
@property (nonatomic, copy) NSString *cmt_type;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) NSInteger precid;
@property (nonatomic, assign) NSInteger preuid;
@property (nonatomic, assign) NSInteger status;

@property (nonatomic, copy) NSString *image;
@property (nonatomic, assign) NSInteger image_width;
@property (nonatomic, assign) NSInteger image_height;

@property (nonatomic, assign,readonly) CGFloat cellHeight;
@property (nonatomic, assign,readonly) CGRect middleFrame;

@property (strong , nonatomic) TGCommentNewM * precmt;
@property (nonatomic, assign,getter=is_voicePlaying) BOOL voicePlaying;
@end
