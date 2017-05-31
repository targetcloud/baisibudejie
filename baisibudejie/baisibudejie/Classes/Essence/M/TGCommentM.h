//
//  TGCommentM.h
//  baisibudejie
//
//  Created by targetcloud on 2017/5/23.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TGUserM;

@interface TGCommentM : NSObject
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *content;
@property (strong , nonatomic)TGUserM *user;
@property (nonatomic, assign) NSInteger like_count;
@property (nonatomic, assign) NSInteger voicetime;
@property (nonatomic, copy) NSString *voiceuri;
@property (nonatomic, copy) NSString *ctime;
@property (nonatomic, assign,getter=is_voicePlaying) BOOL voicePlaying;
@end
