//
//  TGSeeBigPicNewVC.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/30.
//  Copyright © 2017年 targetcloud. All rights reserved.
//  Blog http://blog.csdn.net/callzjy
//  Mail targetcloud@163.com
//  Github https://github.com/targetcloud

#import "TGSeeBigPicNewVC.h"
#import "TGTopicNewM.h"
#import <SVProgressHUD.h>
#import <Photos/Photos.h>
#import <FLAnimatedImage.h>
#import <DALabeledCircularProgressView.h>

@interface TGSeeBigPicNewVC ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (nonatomic, weak) UIScrollView *scrollV;
@property (nonatomic, weak) FLAnimatedImageView *imageV;
@property (weak, nonatomic) IBOutlet DALabeledCircularProgressView  *progressV;
/** 当前App对应的自定义相册 */
- (PHAssetCollection *)createdCollection;//声明为了点语法 self.createdCollection
/** 返回刚才保存到【相机胶卷】的图片 */
- (PHFetchResult<PHAsset *> *)createdAssets;//声明为了点语法 self.createdAssets
@end

@implementation TGSeeBigPicNewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    TGLog(@"viewDidLoad %@",NSStringFromCGRect(self.view.bounds))//{{0, 0}, {600, 600}}
    self.progressV.roundedCorners = YES;
    self.progressV.progressLabel.textColor = [UIColor redColor];
    //self.progressV.trackTintColor = [UIColor clearColor];
    self.progressV.progressTintColor = [UIColor lightGrayColor];
    self.progressV.hidden = YES;
    self.progressV.progressLabel.text = @"";
    [self.progressV setProgress:self.topic.picProgress animated:NO];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    //    scrollView.backgroundColor = [UIColor blueColor];
    scrollView.frame = [UIScreen mainScreen].bounds;//不用self.view.bounds，从XIB出来不准
    //如果用self.vew.bounds，那么要加一句 scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; 但这里仍然不用，因为后面要根据SV做计算，另外的做法也可以把控件的创建移至懒加载,viewDidLayoutSubviews布局控件位置
    //    scrollView.frame = self.view.bounds;
    //    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back)]];
    [self.view insertSubview:scrollView atIndex:0];//不要挡返回和保存按钮
    _scrollV = scrollView;
    
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.width = scrollView.width;
    imageView.height = imageView.width * self.topic.height / self.topic.width;
    scrollView.contentSize = CGSizeMake(0, imageView.height);
    _imageV = imageView;
    [scrollView addSubview:imageView];
    
    //TGLog(@"%@,%@",NSStringFromCGRect(imageView.frame),self.topic.image)
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_imageV tg_setOriginImage:self.topic.image thumbnailImage:self.topic.image_small placeholder:nil progress:^(NSInteger receivedSize, NSInteger expectedSize,NSURL * _Nullable targetURL) {
            self.progressV.hidden = NO;
            CGFloat progress = 1.0 * receivedSize / expectedSize;
            self.topic.picProgress = progress<=0.01 ? 0.01 : progress;
            [self.progressV setProgress:self.topic.picProgress animated:YES];
            [self.progressV.progressLabel setText:[NSString stringWithFormat:@"%.0f%%",self.topic.picProgress * 100]];
            TGLog(@"%f,%@,%@",progress,self.progressV.progressLabel.text,NSStringFromCGRect(self.progressV.progressLabel.frame));
        }  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!image) return;
            if (error){
                TGLog(@"%@",error)
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progressV.hidden = YES;
                _saveBtn.enabled = YES;
                
                //如果图片的大小与topic不一样，则重新设置，以image为准
                CGFloat w = CGImageGetWidth(image.CGImage);
                CGFloat h = CGImageGetHeight(image.CGImage);
                _imageV.height = _imageV.width * h / w;
                _scrollV.contentSize = CGSizeMake(0, _imageV.height);
                //TGLog(@"实际宽高 %f,%f | 模型宽高 %ld,%ld | 图片控件宽高%f,%f",w,h,self.topic.width,self.topic.height,_imageV.width,_imageV.height);
                
                _imageV.x = 0;
                if (_imageV.height > ScreenH) {
                    _imageV.y = 0;
                } else {
                    _imageV.centerY = _scrollV.height * 0.5;
                }
                
                CGFloat maxScale = w / _imageV.width;
                if (maxScale > 1) {
                    _scrollV.maximumZoomScale = maxScale;
                    _scrollV.delegate = self;
                }
            });
        }];
    });
    
    if ([self.topic.images_gif.pathExtension.lowercaseString isEqualToString:@"gif"]) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            FLAnimatedImage *flImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.topic.images_gif]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageV.animatedImage = flImage;
            });
        });
    }
    //    TGLog(@"%zd",scrollView.autoresizingMask)//自己代码加的为0 ，如果是XIB加的为18
}

//-(void) viewDidAppear:(BOOL)animated{
//    TGLog(@"viewDidAppear %@",NSStringFromCGRect(self.view.bounds))//{{0, 0}, {414, 736}}
//}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageV;
}

- (PHAssetCollection *)createdCollection{
    NSString *title = [NSBundle mainBundle].infoDictionary[(__bridge NSString *)kCFBundleNameKey];
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:title]) {
            return collection;
        }
    }
    
    NSError *error = nil;
    __block NSString *createdCollectionID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdCollectionID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (error) return nil;
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCollectionID] options:nil].firstObject;
}

- (PHFetchResult<PHAsset *> *)createdAssets{
    NSError *error = nil;
    __block NSString *assetID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{//同步
        assetID = [PHAssetChangeRequest creationRequestForAssetFromImage:_imageV.image].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    if (error) return nil;
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil];
}

- (IBAction)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save {
    if (self.imageV.image == nil){
        [SVProgressHUD showErrorWithStatus:@"图片未下载！"];
        return;
    }
    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{//弹提示放主线程
            if (status == PHAuthorizationStatusDenied) { // 用户拒绝当前App访问相册 2
                if (oldStatus != PHAuthorizationStatusNotDetermined) {
                    [SVProgressHUD showErrorWithStatus:@"若要保存图片请允许APP访问你的相册！"];
                }
            } else if (status == PHAuthorizationStatusAuthorized) { // 用户允许当前App访问相册 3
                [self saveImageIntoAlbum];
            } else if (status == PHAuthorizationStatusRestricted) { // 无法访问相册
                [SVProgressHUD showErrorWithStatus:@"因系统原因，无法访问相册！"];
            }
        });
    }];
}

- (void)saveImageIntoAlbum{
    PHFetchResult<PHAsset *> *createdAssets = self.createdAssets;
    if (createdAssets == nil) {
        [SVProgressHUD showErrorWithStatus:@"保存相机图片失败！"];
        return;
    }
    
    PHAssetCollection *createdCollection = self.createdCollection;
    if (createdCollection == nil) {
        [SVProgressHUD showErrorWithStatus:@"创建或者获取相册失败！"];
        return;
    }
    
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
        [request insertAssets:createdAssets atIndexes:[NSIndexSet indexSetWithIndex:0]];//最近保存的图片成为封面
    } error:&error];
    if (error) {
        [SVProgressHUD showErrorWithStatus:@"保存图片失败！"];
    } else {
        [SVProgressHUD showSuccessWithStatus:@"保存图片成功！"];
    }
}


@end
