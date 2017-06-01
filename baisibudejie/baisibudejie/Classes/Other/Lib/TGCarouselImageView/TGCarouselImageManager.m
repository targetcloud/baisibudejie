//
//  TGCarouselImageManager.m
//  baisibudejie
//
//  Created by targetcloud on 2017/6/1.
//  Copyright © 2017年 targetcloud. All rights reserved.
//  Blog http://blog.csdn.net/callzjy
//  Mail targetcloud@163.com
//  Github https://github.com/targetcloud

#import "TGCarouselImageManager.h"

#define TGImagesDirectory      [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] \
stringByAppendingPathComponent:NSStringFromClass([self class])]
#define TGImageName(URLString) [URLString lastPathComponent]
#define TGImagePath(URLString) [TGImagesDirectory stringByAppendingPathComponent:TGImageName(URLString)]

@interface TGCarouselImageManager ()
@property (nonatomic, strong) NSMutableDictionary *redownloadManager;
@end

@implementation TGCarouselImageManager
+ (void)load {
    NSString *imagesDirectory = TGImagesDirectory;
    BOOL isDirectory = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExists = [fileManager fileExistsAtPath:imagesDirectory isDirectory:&isDirectory];
    if (!isExists || !isDirectory) {
        [fileManager createDirectoryAtPath:imagesDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (NSMutableDictionary *)redownloadManager {
    if (!_redownloadManager) {
        _redownloadManager = [NSMutableDictionary dictionary];
    }
    return _redownloadManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _repeatCountWhenDownloadFailed = 2;
    }
    return self;
}

- (UIImage *)imageFromSandboxWithImageURLString:(NSString *)imageURLString {
    NSString *imagePath = TGImagePath(imageURLString);
    NSData *data = [NSData dataWithContentsOfFile:imagePath];
    if (data.length > 0 ) {
        return [UIImage imageWithData:data];
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:NULL];
    }
    return nil;
}

- (void)downloadImageURLString:(NSString *)imageURLString imageIndex:(NSInteger)imageIndex {
    UIImage *image = [self imageFromSandboxWithImageURLString:imageURLString];
    if (image) {
        !(self.downloadImageSuccess) ? : self.downloadImageSuccess(image, imageIndex);
        return;
    }
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:imageURLString]
                                 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if (error) {
                                             [self redownloadWithImageURLString:imageURLString imageIndex:imageIndex error:error];
                                             return;
                                         }
                                         UIImage *image = [UIImage imageWithData:data];
                                         if (!image) {
                                             return;
                                         }
                                         !(self.downloadImageSuccess) ? : self.downloadImageSuccess(image, imageIndex);
                                         if (![data writeToFile:TGImagePath(imageURLString) atomically:YES]) {
                                             NSLog(@"%@ writeToFile %@ Failed!",NSStringFromClass([self class]),TGImagePath(imageURLString));
                                         }
                                     });
                                 }] resume];
}

- (void)redownloadWithImageURLString:(NSString *)imageURLString imageIndex:(NSInteger)imageIndex error:(NSError *)error {
    NSNumber *redownloadNumber = self.redownloadManager[imageURLString];
    NSInteger redownloadTimes = redownloadNumber ? redownloadNumber.integerValue : 0;
    if (self.repeatCountWhenDownloadFailed > redownloadTimes) {
        self.redownloadManager[imageURLString] = @(++redownloadTimes);
        [self downloadImageURLString:imageURLString imageIndex:imageIndex];
        return;
    }
    !(self.downloadImageFailure) ? : self.downloadImageFailure(error, imageURLString);
}

+ (void)clearCachedImages {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileNames = [fileManager contentsOfDirectoryAtPath:TGImagesDirectory error:nil];
    for (NSString *fileName in fileNames) {
        if (![fileManager removeItemAtPath:[TGImagesDirectory stringByAppendingPathComponent:fileName] error:nil]) {
            NSLog(@"%@ removeItemAtPath %@ Failed!",NSStringFromClass(self),[TGImagesDirectory stringByAppendingPathComponent:fileName]);
        }
    }
}

@end
