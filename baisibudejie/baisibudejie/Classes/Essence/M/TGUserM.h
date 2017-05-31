//
//  TGUserM.h
//  baisibudejie
//
//  Created by targetcloud on 2017/5/23.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGUserM : NSObject
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *profile_image;
@property (nonatomic, assign) NSInteger total_cmt_like_count;
@end
