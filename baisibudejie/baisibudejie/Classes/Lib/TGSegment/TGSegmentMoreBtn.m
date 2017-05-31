//
//  TGSegmentMoreBtn.m
//  TGSegment
//
//  Created by targetcloud on 2017/4/18.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGSegmentMoreBtn.h"
@interface TGSegmentMoreBtn()
@property (nonatomic, assign) CGFloat radio;
@end

@implementation TGSegmentMoreBtn

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

-(CGFloat)radio {
    return 0.9;
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(0, 0, contentRect.size.width * self.radio, contentRect.size.height);
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    return CGRectMake(contentRect.size.width * self.radio * self.radio, 0, contentRect.size.width * ( 1 - self.radio), contentRect.size.height);
}

@end
