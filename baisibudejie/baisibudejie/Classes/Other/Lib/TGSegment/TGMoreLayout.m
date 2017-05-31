//
//  TGMoreLayout.m
//  TGSegment
//
//  Created by targetcloud on 2017/4/23.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGMoreLayout.h"
@interface TGMoreLayout()
@property (nonatomic, strong) NSMutableDictionary *heights;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, copy) HeightBlock block;
@end
    
@implementation TGMoreLayout
- (instancetype)init{
    self = [super init];
    if (self) {
        self.cols = 3;
        self.minimumLineSpacing = 10.0f;
        self.minimumInteritemSpacing = 10.0f;
        self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        _heights = [NSMutableDictionary dictionary];
        _array = [NSMutableArray array];
    }
    return self;
}

- (void)prepareLayout{
    [super prepareLayout];
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (NSInteger i = 0; i < self.cols ; i++) {
        [_heights setObject:@(self.sectionInset.top) forKey:[NSString stringWithFormat:@"%ld",i]];
    }
    for (NSInteger i = 0 ; i < count; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [_array addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
}

- (CGSize)collectionViewContentSize{
    __block NSString *heightIndex = @"0";
    [_heights enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *obj, BOOL *stop) {
        if ([_heights[heightIndex] floatValue] < [obj floatValue] ) {
            heightIndex = key;
        }
    }];
    return CGSizeMake(self.collectionView.bounds.size.width, [_heights[heightIndex] floatValue] + self.sectionInset.bottom);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    CGFloat itemW = (self.collectionView.bounds.size.width - (self.sectionInset.left + self.sectionInset.right) - (self.cols - 1) * self.minimumInteritemSpacing) / self.cols;
    CGFloat itemH = 0;
    if (self.block != nil) {
        itemH = self.block(indexPath, itemW) + 2;//+2是为了容错计算
    }else{
        NSAssert(itemH != 0,@"请实现 computeIndexCellHeightWithWidthBlock");
    }
    if (self.minCellH>0 && itemH<self.minCellH){
        itemH = self.minCellH;
    }
    CGRect frame;
    frame.size = CGSizeMake(itemW, itemH);
    __block NSString *heightIndex = @"0";
    [_heights enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *obj, BOOL *stop) {
        if ([_heights[heightIndex] floatValue] > [obj floatValue]) {
            heightIndex = key;
        }
    }];
    frame.origin = CGPointMake(self.sectionInset.left + [heightIndex intValue] * (itemW + self.minimumInteritemSpacing), [_heights[heightIndex] floatValue]);
    _heights[heightIndex] = @(frame.size.height + self.minimumLineSpacing + [_heights[heightIndex] floatValue]);
    attr.frame = frame;
    return attr;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    return _array;
}

- (void)computeIndexCellHeightWithWidthBlock:(CGFloat (^)(NSIndexPath *, CGFloat))block{
    if (self.block != block) {
        self.block = block;
    }
}
@end
