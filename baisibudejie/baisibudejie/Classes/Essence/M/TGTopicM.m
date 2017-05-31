//
//  TGTopicM.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/12.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGTopicM.h"
#import "TGCommentM.h"
#import "TGUserM.h"

@implementation TGTopicM
{
    CGFloat _cellHeight;
    CGFloat _commentBtnX;
    CGFloat _commentVH;
    CGRect _middleFrame;
}

/*
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"top_cmt" : [TGCommentM class]
             };
}
*/

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"ID" : @"id",
             @"top_cmt" : @"top_cmt[0]",
             };
}

- (CGFloat)cellHeight{
    if (_cellHeight) return _cellHeight;
    _commentVH = 0;
    _commentBtnX = 0;
    _cellHeight += 55;

    CGSize textMaxSize = CGSizeMake(ScreenW - 2 * Margin , MAXFLOAT);
    _cellHeight += [self.text boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size.height + Margin;
    //   [self.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:textMaxSize].height;
    
    if (self.type != TGTopicTypeWord) { //图片、声音、视频
        CGFloat middleW = textMaxSize.width;
        CGFloat middleH = middleW * self.height / self.width;
        if (middleH >= ScreenH) { // 显示的图片高度超过一个屏幕，就是超长图片
            middleH = 300;
            _bigPicture = YES;
        }
        CGFloat middleY = _cellHeight;
        CGFloat middleX = Margin;
        _middleFrame = CGRectMake(middleX, middleY, middleW, middleH);
        _cellHeight += middleH + Margin;
    }
    
    if (self.top_cmt.content.length > 0){//评论
        /*
        NSDictionary *cmt = self.top_cmt[0];
        NSString *content = cmt[@"content"];
        if (content.length == 0) {
            content = @"[语音评论]";
        }
        NSString *username = cmt[@"user"][@"username"];
        NSString *cmtText = [NSString stringWithFormat:@"%@ : %@", username, content];
        */
        NSString *content = self.top_cmt.content;
        NSString *username = self.top_cmt.user.username;
        NSString *cmtText = [NSString stringWithFormat:@"%@ : %@", username, content];
        
        textMaxSize = CGSizeMake(ScreenW - 2 * Margin - 10, MAXFLOAT);//再减10是评论区域内的左右边距
        _commentVH = [cmtText boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]} context:nil].size.height + 30;//30为最热评论这四个字的固定高度加上边距
        _cellHeight += _commentVH;
    }else if (self.top_cmt.voiceuri.length>0){
        NSString *username = self.top_cmt.user.username;
        NSString *cmtText = [NSString stringWithFormat:@"%@ : %@", username, @""];
        textMaxSize = CGSizeMake(ScreenW - 2 * Margin - 10, MAXFLOAT);//再减10是评论区域内的左右边距
        _commentBtnX = [cmtText boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]} context:nil].size.width + Margin;
        _commentVH = 40 + 30;//前40为按钮高
        _cellHeight += _commentVH;
    }
    _cellHeight += 35 ;//工具条
    return _cellHeight;
}

- (NSString *)passtime{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *create = [fmt dateFromString:_passtime];
    if (create.isThisYear) { // 今年
        if (create.isToday) { // 今天
            NSDateComponents *cmps = [[NSDate date] deltaFrom:create];
            if (cmps.hour >= 1) { // 时间差距 >= 1小时
                return [NSString stringWithFormat:@"%zd小时前", cmps.hour];
            } else if (cmps.minute >= 1) { // 1小时 > 时间差距 >= 1分钟
                return [NSString stringWithFormat:@"%zd分钟前", cmps.minute];
            } else { // 1分钟 > 时间差距
                return @"刚刚";
            }
        } else if (create.isYesterday) { // 昨天
            fmt.dateFormat = @"昨天 HH:mm:ss";
            return [fmt stringFromDate:create];
        } else { // 其他
            fmt.dateFormat = @"MM-dd HH:mm:ss";
            return [fmt stringFromDate:create];
        }
    } else { // 非今年
        return _passtime;
    }
}
@end
