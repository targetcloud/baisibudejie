//
//  UIImageView+download.h
//  baisibudejie
//
//  Created by targetcloud on 2017/3/6.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIImageView+WebCache.h>

@interface UIImageView (download)
- (void)tg_setOriginImage:(NSString *_Nullable)originImageURL thumbnailImage:(NSString *_Nullable)thumbnailImageURL placeholder:(UIImage *_Nullable)placeholder progress:(nullable SDWebImageDownloaderProgressBlock)progressBlock completed:(SDExternalCompletionBlock _Nullable )completedBlock;
- (void)tg_setHeader:(NSString *_Nonnull)headerUrl;
- (void)tg_setHeader:(NSString *_Nonnull)headerUrl borderWidth:(CGFloat)borderWidth borderColor:(UIColor *_Nullable)borderColor;
@end
