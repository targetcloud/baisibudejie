//
//  TGCommentNewM.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/30.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGCommentNewM.h"

@implementation TGCommentNewM
{
    CGFloat _cellHeight;
    CGRect _middleFrame;
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"ID" : @"id",
             @"precmt" : @"precmts[0]",
             @"voiceuri" : @"audio.audio[0]",
             @"voicetime" : @"audio.duration",
             @"image" : @"image.images[0]",
             @"image_width" : @"image.width",
             @"image_height" : @"image.height",
             @"video_width" : @"video.width",
             @"video_height" : @"video.height",
             @"videotime" : @"video.duration",
             @"videouri" : @"video.video[0]",
             @"video_thumbnail" : @"video.thumbnail[0]",
             };
}

- (CGFloat)cellHeight{
    if (_cellHeight) return _cellHeight;
    _cellHeight += 55;
    
    CGSize textMaxSize = CGSizeMake(ScreenW - 45 - 10, MAXFLOAT);
    if (self.videouri.length>0){
        CGFloat middleW = self.video_width>textMaxSize.width ? textMaxSize.width : self.video_width;
        CGFloat middleH = self.video_width>textMaxSize.width ? middleW * self.video_height / self.video_width : self.video_height;
        CGFloat middleY = _cellHeight - 15;
        CGFloat middleX = 45;
        _middleFrame = CGRectMake(middleX, middleY, middleW, middleH);
        _cellHeight += middleH;
    }else if (self.image.length>0) {
        CGFloat middleW = self.image_width>textMaxSize.width ? textMaxSize.width : self.image_width;
        CGFloat middleH = self.image_width>textMaxSize.width ? middleW * self.image_height / self.image_width : self.image_height;
        CGFloat middleY = _cellHeight - 15;
        CGFloat middleX = 45;
        _middleFrame = CGRectMake(middleX, middleY, middleW, middleH);
        _cellHeight += middleH;
    }else if (self.voiceuri.length>0){
        CGFloat middleW = 115;
        CGFloat middleH = 40;
        CGFloat middleY = _cellHeight - 15;
        CGFloat middleX = 45;
        _middleFrame = CGRectMake(middleX, middleY, middleW, middleH);
        _cellHeight += middleH;
    }else  if (self.content.length>0){
        _cellHeight += [self.content boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size.height;
    }
    _cellHeight = _cellHeight < 80 ? 80 : _cellHeight;
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

- (NSString *)ctime{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    _ctime = [_ctime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *create = [fmt dateFromString:_ctime];
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
        return _ctime;
    }
}
@end
