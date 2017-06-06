//
//  UIImageView+download.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/6.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "UIImageView+download.h"
#import <UIImageView+WebCache.h>
#import <AFNetworkReachabilityManager.h>

@implementation UIImageView (download)
- (void)tg_setHeader:(NSString *)headerUrl{
    UIImage *placeholder = [UIImage tg_circleImageNamed:@"defaultUserIcon"];
    [self sd_setImageWithURL:[NSURL URLWithString:headerUrl] placeholderImage:placeholder options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image) return;
        self.image = [image tg_circleImage];
    }];
}
/*
typedef void(^SDExternalCompletionBlock)(UIImage * _Nullable image,                          NSError * _Nullable error, SDImageCacheType cacheType,                NSURL * _Nullable imageURL);
typedef void(^SDInternalCompletionBlock)(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL);

typedef void(^SDWebImageCompletionBlock)(UIImage *           image,                          NSError *           error, SDImageCacheType cacheType,                NSURL *           imageURL);
*/
- (void)tg_setOriginImage:(NSString *)originImageURL thumbnailImage:(NSString *)thumbnailImageURL placeholder:(UIImage *)placeholder progress:(nullable SDWebImageDownloaderProgressBlock)progressBlock completed:(SDExternalCompletionBlock)completedBlock{
    
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    UIImage *originImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:originImageURL];
    if (originImage) {
        /*
        self.image = originImage;
        completedBlock(originImage, nil, 0, [NSURL URLWithString:originImageURL]);
         这两句不能用，要换成下面一句，原因是SD会调用[self sd_cancelImageLoadOperationWithKey:validOperationKey];防止cell重用出错
         */
        [self sd_setImageWithURL:[NSURL URLWithString:originImageURL] placeholderImage:placeholder options:0 progress:progressBlock completed:completedBlock];
    } else {
        if (mgr.isReachableViaWiFi) {
            [self sd_setImageWithURL:[NSURL URLWithString:originImageURL] placeholderImage:placeholder options:0 progress:progressBlock completed:completedBlock];
        } else if (mgr.isReachableViaWWAN) {
            BOOL downloadOriginImageWhen3GOr4G = YES;
            if (downloadOriginImageWhen3GOr4G) {
                [self sd_setImageWithURL:[NSURL URLWithString:originImageURL] placeholderImage:placeholder options:0 progress:progressBlock completed:completedBlock];
            } else {
                [self sd_setImageWithURL:[NSURL URLWithString:thumbnailImageURL] placeholderImage:placeholder options:0 progress:progressBlock completed:completedBlock];
            }
        } else {
            UIImage *thumbnailImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:thumbnailImageURL];
            if (thumbnailImage) {
                /*
                self.image = thumbnailImage;
                completedBlock(thumbnailImage, nil, 0, [NSURL URLWithString:thumbnailImageURL]);
                 */
                [self sd_setImageWithURL:[NSURL URLWithString:thumbnailImageURL] placeholderImage:placeholder options:0 progress:progressBlock completed:completedBlock];
            } else {
                /*
                self.image = placeholder;
                */
                [self sd_setImageWithURL:nil placeholderImage:placeholder options:0 progress:progressBlock completed:completedBlock];
            }
        }
    }
}
@end
