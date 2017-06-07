//
//  TGTopicNewCell.h
//  baisibudejie
//
//  Created by targetcloud on 2017/5/30.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TGTopicNewM;

typedef void (^ReloadRowsAtIndexPathBlock)();

@interface TGTopicNewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *spreadV;
@property (nonatomic, strong) TGTopicNewM *topic;
@property (nonatomic, copy) ReloadRowsAtIndexPathBlock block;
@property (nonatomic, copy) void (^upBlock)(NSString * topicId);
@property (nonatomic, copy) void (^downBlock)(NSString * topicId);
@property (nonatomic, copy) void (^repostBlock)(NSString * topicId);
@property (nonatomic, copy) void (^commentBlock)(NSString * topicId);
@end
