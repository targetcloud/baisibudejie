//
//  TGUserNewM.h
//  baisibudejie
//
//  Created by targetcloud on 2017/5/30.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGUserNewM : NSObject
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *header;//0
@property (nonatomic, copy) NSString *profile_image;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, assign) BOOL is_vip;
@property (nonatomic, assign) BOOL is_v;
@property (nonatomic, assign) NSInteger total_cmt_like_count;
@property (nonatomic, copy) NSString *room_url;
@property (nonatomic, copy) NSString *room_name;
@property (nonatomic, copy) NSString *room_role;
@property (nonatomic, copy) NSString *room_icon;
@property (nonatomic, copy) NSString *qq_uid;
@property (nonatomic, copy) NSString *weibo_uid;
@property (nonatomic, copy) NSString *personal_page;
@property (nonatomic, copy) NSString *qzone_uid;
@end
