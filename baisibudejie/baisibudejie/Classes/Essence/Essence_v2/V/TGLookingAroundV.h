//
//  TGLookingAroundV.h
//  baisibudejie
//
//  Created by targetcloud on 2017/6/9.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TGTopicNewM;
@interface TGLookingAroundV : UICollectionViewCell
@property (nonatomic, strong) TGTopicNewM *topic;
@property (nonatomic, copy) void (^commentBlock)(NSString * topicId);
@property (copy,nonatomic) void (^nextBlock)(NSString * topicId);
-(void) play;
-(void) replacePlayerItem:(TGTopicNewM *)topic;
@end
