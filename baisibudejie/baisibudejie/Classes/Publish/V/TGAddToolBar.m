//
//  TGAddToolBar.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/20.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGAddToolBar.h"
#import "TGAddTagsVC.h"

@interface TGAddToolBar()
@property (weak, nonatomic) IBOutlet UIView *topV;
@property (weak ,nonatomic) UIButton *addBtn;
@property (strong , nonatomic)NSMutableArray *tagLbls;
@end

@implementation TGAddToolBar

-(NSMutableArray *)tagLbls{
    if (!_tagLbls) {
        _tagLbls = [NSMutableArray array];
    }
    return _tagLbls;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    UIButton *addButton = [[UIButton alloc] init];
    [addButton setImage:[UIImage imageNamed:@"tag_add_icon"] forState:UIControlStateNormal];
    addButton.size = addButton.currentImage.size;
    addButton.x = Margin;
    [addButton addTarget:self action:@selector(addBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.topV addSubview:addButton];
    _addBtn = addButton;
    [self creatTags:@[@"姐夫",@"糗事"]];
}

- (void)addBtnClick{
    TGAddTagsVC *addTagsVc = [[TGAddTagsVC alloc]init];
    __weak typeof(self)weakSelf = self;
    addTagsVc.tagsBlock = ^(NSArray *tags){
        [weakSelf creatTags:tags];
    };
    addTagsVc.tags = [self.tagLbls valueForKeyPath:@"text"];
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController *nav = (UINavigationController *)root.presentedViewController;
    [nav pushViewController:addTagsVc animated:YES];
}

- (void)creatTags:(NSArray *)tags{
    [self.tagLbls makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.tagLbls removeAllObjects];
    for (NSInteger i = 0; i < tags.count; i++) {
        UILabel *tagLbl = [[UILabel alloc] init];
        tagLbl.backgroundColor = TagBgColor;
        tagLbl.text = tags[i];
        tagLbl.textColor = TagTitleColor;//[UIColor whiteColor];
        tagLbl.textAlignment = NSTextAlignmentCenter;
        tagLbl.font = TagFont;
        [tagLbl sizeToFit];
        tagLbl.height = self.addBtn.height;
        tagLbl.width += 2 * TagMargin;
        tagLbl.layer.masksToBounds = YES;
        tagLbl.layer.cornerRadius = 5;
        [self.topV addSubview:tagLbl];
        [self.tagLbls addObject:tagLbl];
    }
    [self setNeedsLayout];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    for (NSInteger i = 0; i < self.tagLbls.count; i++) {
        UILabel *tagLbl = self.tagLbls[i];
        if (i == 0) {
            tagLbl.x = 0;
            tagLbl.y = 0;
        }else{
            UILabel *lastTagLbl = _tagLbls[i - 1];
            CGFloat leftWidth = CGRectGetMaxX(lastTagLbl.frame) + TagMargin;
            CGFloat rightWidth = self.topV.width - leftWidth;
            if (rightWidth >= tagLbl.width) {
                tagLbl.y = lastTagLbl.y;
                tagLbl.x = leftWidth;
            }else{
                tagLbl.x = 0;
                tagLbl.y = CGRectGetMaxY(lastTagLbl.frame) + TagMargin;
            }
        }
    }
    UILabel *lastTagLbl = [self.tagLbls lastObject];
    CGFloat leftWidth = CGRectGetMaxX(lastTagLbl.frame) + TagMargin;
    if (self.topV.width - leftWidth >= self.addBtn.width) {
        self.addBtn.x = leftWidth;
        self.addBtn.y = lastTagLbl.y;
    }else{
        self.addBtn.x = 0;
        self.addBtn.y = CGRectGetMaxY(lastTagLbl.frame) + TagMargin;
    }
    
    CGFloat oldHeight = self.height;
    self.height = CGRectGetMaxY(self.addBtn.frame) + 40;
    self.y -= self.height - oldHeight;
}


@end
