//
//  TGCarouselImageView.m
//  baisibudejie
//
//  Created by targetcloud on 2017/6/1.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGCarouselImageView.h"
#import "TGCarouselImageManager.h"

@interface TGCarouselImageView () <UIScrollViewDelegate>
@property (nonatomic, weak) id<TGCarouselImageViewDelegate>     delegate;
@property (nonatomic, copy) DidTapCarouselImageViewAtIndexBlock block;
@property (nonatomic, strong) TGCarouselImageManager           *imageManager;
@property (nonatomic, strong) NSMutableArray                   *images;
@property (nonatomic, strong) NSArray                          *imageArray;
@property (nonatomic, strong) NSArray                          *describeArray;
@property (nonatomic, strong) UIImage                          *placeholderImage;
@property (nonatomic, strong) UIScrollView                     *scrollView;
@property (nonatomic, strong) UIImageView                      *currentImageView;
@property (nonatomic, strong) UIImageView                      *nextImageView;
@property (nonatomic, strong) UIView                           *bottomContainer;
@property (nonatomic, strong) UIPageControl                    *pageControl;
@property (nonatomic, strong) UILabel                          *descLabel;
@property (nonatomic, assign) NSInteger                        currentIndex;
@property (nonatomic, assign) NSInteger                        nextIndex;
@property (nonatomic, strong) NSTimer                         *autoPagingTimer;
@end

@implementation TGCarouselImageView

#pragma mark - Lazy
- (TGCarouselImageManager *)imageManager {
    if (!_imageManager) {
        __weak typeof(self) weakSelf = self;
        _imageManager = [[TGCarouselImageManager alloc] init];
        _imageManager.downloadImageSuccess = ^(UIImage *image, NSInteger imageIndex) {
            weakSelf.images[imageIndex] = image;
            if (weakSelf.currentIndex == imageIndex) {
                weakSelf.currentImageView.image = image;
            }
        };
        _imageManager.downloadImageFailure = ^(NSError *error, NSString *imageURLString) {
            NSLog(@"downloadImageFailure %@ error: %@", imageURLString,error);
        };
    }
    return _imageManager;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.textColor = [UIColor whiteColor];
        _descLabel.font = [UIFont systemFontOfSize:14];
        _descLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_descLabel];
    }
    return _descLabel;
}

#pragma mark - Init
+ (instancetype)tg_carouselImageViewWithFrame:(CGRect)frame imageArrary:(NSArray *)imageArrary {
    return [self tg_carouselImageViewWithFrame:frame imageArrary:imageArrary describeArray:nil];
}

+ (instancetype)tg_carouselImageViewWithFrame:(CGRect)frame imageArrary:(NSArray *)imageArrary describeArray:(NSArray *)describeArray {
    return [self tg_carouselImageViewWithFrame:frame imageArrary:imageArrary describeArray:describeArray placeholderImage:nil];
}

+ (instancetype)tg_carouselImageViewWithFrame:(CGRect)frame imageArrary:(NSArray *)imageArrary describeArray:(NSArray *)describeArray placeholderImage:(UIImage *)placeholderImage {
    return [self tg_carouselImageViewWithFrame:frame imageArrary:imageArrary describeArray:describeArray placeholderImage:placeholderImage delegate:nil];
}

+ (instancetype)tg_carouselImageViewWithFrame:(CGRect)frame imageArrary:(NSArray *)imageArrary describeArray:(NSArray *)describeArray placeholderImage:(UIImage *)placeholderImage delegate:(id<TGCarouselImageViewDelegate>)delegate {
    return [[self alloc] initWithFrame:frame imageArrary:imageArrary describeArray:describeArray placeholderImage:placeholderImage delegate:delegate];
}

- (instancetype)initWithFrame:(CGRect)frame imageArrary:(NSArray *)imageArrary describeArray:(NSArray *)describeArray placeholderImage:(UIImage *)placeholderImage delegate:(id<TGCarouselImageViewDelegate>)delegate {
    if (self = [super init]) {
        self.frame = frame;
        _imageArray       = imageArrary;
        _describeArray    = describeArray;
        _placeholderImage = placeholderImage;
        _delegate = delegate;
        _images = [NSMutableArray array];
        _currentIndex = 0;
        _nextIndex    = 0;
        [self setupUI];
        [self startAutoPagingTimer];
    }
    return self;
}

+ (instancetype)tg_carouselImageViewWithFrame:(CGRect)frame imageArrary:(NSArray *)imageArrary describeArray:(NSArray *)describeArray placeholderImage:(UIImage *)placeholderImage block:(DidTapCarouselImageViewAtIndexBlock)block {
    return [[self alloc] initWithFrame:frame imageArrary:imageArrary describeArray:describeArray placeholderImage:placeholderImage block:block];
}

- (instancetype)initWithFrame:(CGRect)frame imageArrary:(NSArray *)imageArrary describeArray:(NSArray *)describeArray placeholderImage:(UIImage *)placeholderImage block:(DidTapCarouselImageViewAtIndexBlock)block {
    if (self = [super init]) {
        self.frame = frame;
        _imageArray       = imageArrary;
        _describeArray    = describeArray;
        _placeholderImage = placeholderImage;
        _block = block;
        _images = [NSMutableArray array];
        _currentIndex = 0;
        _nextIndex    = 0;
        [self setupUI];
        [self startAutoPagingTimer];
    }
    return self;
}

#pragma mark - Setup
- (void)setupUI {
    if (_imageArray.count == 0) {
        return;
    }
    [self setupSubviews];
    [self setupImages];
    [self setupImageDescribes];
}

- (void)setupSubviews {
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    [self addSubview:_scrollView];
    
    _currentImageView = [[UIImageView alloc] init];
    _currentImageView.contentMode = UIViewContentModeScaleToFill;//UIViewContentModeScaleAspectFill;
    _currentImageView.userInteractionEnabled = YES;
    [_currentImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCurrentImageView)]];
    [_scrollView addSubview:_currentImageView];
    
    _nextImageView = [[UIImageView alloc] init];
    _nextImageView.contentMode = UIViewContentModeScaleToFill;//UIViewContentModeScaleAspectFill;
    [_scrollView addSubview:_nextImageView];
    
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.hidesForSinglePage = YES;
    _pageControl.userInteractionEnabled = NO;
    _pageControl.numberOfPages = _imageArray.count;
    _pageControl.currentPage = 0;
    [self addSubview:_pageControl];
}

- (void)setupImages {
    for (int i = 0; i < _imageArray.count; i++) {
        if ([_imageArray[i] isKindOfClass:[UIImage class]]) {
            [self.images addObject:_imageArray[i]];
        }else if ([_imageArray[i] isKindOfClass:[NSString class]]) {
            if (_placeholderImage) {
                [self.images addObject:_placeholderImage];
            } else {
                [self.images addObject:[NSNull null]];
            }
            [self.imageManager downloadImageURLString:self.imageArray[i] imageIndex:i];
        }
    }
    _currentImageView.image = ([self.images[0] isKindOfClass:[NSNull class]]) ? nil : self.images[0];
}

- (void)setupImageDescribes {
    if (_describeArray && _describeArray.count > 0) {
        if (_describeArray.count < self.images.count) {
            NSMutableArray *arrayM = [NSMutableArray arrayWithArray:_describeArray];
            for (NSInteger i = _describeArray.count; i< self.images.count; i++) {
                [arrayM addObject:@""];
            }
            _describeArray = arrayM;
        }
        _bottomContainer = [[UIView alloc] init];
        _bottomContainer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        [self addSubview:_bottomContainer];
        [_bottomContainer addSubview:self.descLabel];
        self.descLabel.text = _describeArray[0];
        [self bringSubviewToFront:_pageControl];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _scrollView.frame = self.bounds;
    _scrollView.contentInset = UIEdgeInsetsZero;
    CGFloat width = _scrollView.frame.size.width;
    CGFloat height = _scrollView.frame.size.height;
    
    if (self.images.count > 1) {
        _scrollView.contentSize   = CGSizeMake(width * 3, 0);
        _scrollView.contentOffset = CGPointMake(width, 0);
        _currentImageView.frame   = CGRectMake(width, 0, width, height);
    } else {
        _scrollView.contentSize   = CGSizeZero;
        _scrollView.contentOffset = CGPointMake(0, 0);
        _currentImageView.frame   = CGRectMake(0, 0, width, height);
    }
    
    CGFloat bottomContainerHeight = 25;
    CGFloat pageControlDotWidth = 15;
    if (!_describeArray || _describeArray.count == 0) {
        _pageControl.frame = CGRectMake(width * 0.5 - _pageControl.numberOfPages * pageControlDotWidth * 0.5, height - bottomContainerHeight,
                                        _pageControl.numberOfPages * pageControlDotWidth, bottomContainerHeight);
    } else {
        _bottomContainer.frame = CGRectMake(0, height - bottomContainerHeight, width, bottomContainerHeight);
        _pageControl.frame = CGRectMake(width - _pageControl.numberOfPages * pageControlDotWidth - 5, height - bottomContainerHeight,
                                        _pageControl.numberOfPages * pageControlDotWidth, bottomContainerHeight);
        _descLabel.frame = CGRectMake(5, 0, width - 5 * 2, bottomContainerHeight);
    }
}

#pragma mark - Timer
- (void)startAutoPagingTimer {
    if (self.images.count <= 1) {
        return;
    }
    if (_autoPagingTimer) {
        [self stopAutoPagingTimer];
    }
    _autoPagingTimer = [NSTimer timerWithTimeInterval:_autoPagingInterval == 0 ? 3.0 : _autoPagingInterval
                                               target:self
                                             selector:@selector(nextPage)
                                             userInfo:nil
                                              repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_autoPagingTimer forMode:NSRunLoopCommonModes];
}

- (void)stopAutoPagingTimer {
    if (_autoPagingTimer) {
        [_autoPagingTimer invalidate];
        _autoPagingTimer = nil;
    }
}

- (void)nextPage {
    CGFloat width = _scrollView.frame.size.width;
    [_scrollView setContentOffset:CGPointMake(width * 2, 0) animated:YES];
}

#pragma mark - Actions
- (void)didTapCurrentImageView {
    !([self.delegate respondsToSelector:@selector(didTapCarouselImageViewAtIndex:)]) ? : [self.delegate didTapCarouselImageViewAtIndex:self.currentIndex];
    !(self.block) ? : self.block(self.currentIndex);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat width = _scrollView.frame.size.width;
    CGFloat height = _scrollView.frame.size.height;
    if (offsetX == width) {
        return;
    }
    if (offsetX > width) {
        _nextImageView.frame = CGRectMake(CGRectGetMaxX(_currentImageView.frame), 0, width, height);
        _nextIndex = ( (_currentIndex + 1) == self.images.count) ? 0 : _currentIndex + 1;
    }
    if (offsetX < width) {
        _nextImageView.frame = CGRectMake(0, 0, width, height);
        _nextIndex =( (_currentIndex - 1) < 0) ? self.images.count - 1 : _currentIndex - 1;
    }
    _nextImageView.image = ([self.images[_nextIndex] isKindOfClass:[NSNull class]]) ? nil : self.images[_nextIndex];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopAutoPagingTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self startAutoPagingTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateContent];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self updateContent];
}

- (void)updateContent {
    CGFloat width = _scrollView.frame.size.width;
    CGFloat height = _scrollView.frame.size.height;
    CGFloat offsetX = _scrollView.contentOffset.x;
    if (offsetX == width) {
        return;
    }
    _currentIndex = _nextIndex;
    _pageControl.currentPage = _currentIndex;
    self.descLabel.text = self.describeArray[self.currentIndex];
    _currentImageView.image = _nextImageView.image;
    _currentImageView.frame = CGRectMake(width, 0, width, height);
    [_scrollView setContentOffset:CGPointMake(width, 0) animated:NO];
}

#pragma mark - setter
- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    if (_currentPageIndicatorTintColor != currentPageIndicatorTintColor) {
        _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
        _pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    }
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    if (_pageIndicatorTintColor != pageIndicatorTintColor) {
        _pageIndicatorTintColor = pageIndicatorTintColor;
        _pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
    }
}

- (void)setCurrentPageIndicatorImage:(UIImage *)currentPageIndicatorImage {
    if (_currentPageIndicatorImage != currentPageIndicatorImage) {
        _currentPageIndicatorImage = currentPageIndicatorImage;
        [_pageControl setValue:currentPageIndicatorImage forKey:@"_currentPageImage"];
    }
}

-(void)setImageContentMode:(UIViewContentMode)imageContentMode{
    if (_imageContentMode != imageContentMode) {
        _imageContentMode = imageContentMode;
        _currentImageView.contentMode = imageContentMode;
        _nextImageView.contentMode = imageContentMode;
    }
}

- (void)setPageIndicatorImage:(UIImage *)pageIndicatorImage {
    if (_pageIndicatorImage != pageIndicatorImage) {
        _pageIndicatorImage = pageIndicatorImage;
        [_pageControl setValue:pageIndicatorImage forKey:@"_pageImage"];
    }
}

- (void)setAutoPagingInterval:(NSTimeInterval)autoPagingInterval {
    if (_autoPagingInterval != autoPagingInterval) {
        _autoPagingInterval = autoPagingInterval;
        [self startAutoPagingTimer];
    }
}

#pragma mark - dealloc
- (void)dealloc {
    [self stopAutoPagingTimer];
}
@end
