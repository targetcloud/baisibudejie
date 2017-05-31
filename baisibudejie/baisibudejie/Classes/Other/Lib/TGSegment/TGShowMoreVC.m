//
//  TGShowMoreVC.m
//  TGSegment
//
//  Created by targetcloud on 2017/4/18.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGShowMoreVC.h"
#import "TGMoreCell.h"
#import "TGMoreLayout.h"
#import "UIView+TGSegment.h"

#define kScreenW [UIScreen mainScreen].bounds.size.width

@interface TGShowMoreVC ()
@property (nonatomic, strong) TGSegmentConfig *segmentConfig;
@property (nonatomic, strong) TGMoreLayout *waterLayout;
@end

@implementation TGShowMoreVC

static NSString * const reuseIdentifier = @"MoreCell";

- (TGMoreLayout *)waterLayout {
    if (_waterLayout == nil) {
        _waterLayout = [[TGMoreLayout alloc] init];
        __weak typeof(self) weakSelf = self;
        [_waterLayout computeIndexCellHeightWithWidthBlock:^CGFloat(NSIndexPath *indexPath, CGFloat width) {
            NSString *str = (NSString *)weakSelf.items[indexPath.item];
            CGRect rect= [str boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:weakSelf.segmentConfig.showMoreCellFont} context:nil];
            //NSLog(@"%@,%f,%@",weakSelf.segmentConfig.showMoreCellFont,rect.size.height,str);
            return rect.size.height;
        }];
        _waterLayout.sectionInset = UIEdgeInsetsMake(20, 10, 10, 10);
    }
    return _waterLayout;
}

-(void)setItems:(NSArray<NSString *> *)items{
    _items = items;
    [self.collectionView reloadData];
}

- (instancetype)initWithConfig : (TGSegmentConfig *)segmentConfig{
    self.segmentConfig = segmentConfig;
    
    self.waterLayout.minimumLineSpacing = self.segmentConfig.limitMargin;
    self.waterLayout.minimumInteritemSpacing = self.segmentConfig.limitMargin;
    self.waterLayout.cols = self.segmentConfig.showMoreVCRowCount;
    self.waterLayout.minCellH = self.segmentConfig.showMoreCellMinH;
    return [super initWithCollectionViewLayout:self.waterLayout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UINib * nib = [UINib nibWithNibName:@"TGMoreCell" bundle: [NSBundle mainBundle]];
    
    //NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    //UINib *nib = [UINib nibWithNibName:@"TGMoreCell" bundle:currentBundle];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionView.backgroundColor = [UIColor clearColor];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TGMoreCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.menuLabel.text = (NSString *)self.items[indexPath.row];
    cell.backgroundColor = cell.selected ? self.segmentConfig.segSelectedColor : self.segmentConfig.showMoreCellBGColor;
    cell.segmentConfig = self.segmentConfig;
    return cell;
}

@end
