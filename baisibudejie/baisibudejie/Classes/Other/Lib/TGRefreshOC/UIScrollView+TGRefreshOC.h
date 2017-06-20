//
//  UIScrollView+TGRefreshOC.h
//  TGRefreshOC
//
//  Created by targetcloud on 2017/6/20.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGRefreshOC.h"

@class TGRefreshOC;

@interface UIScrollView (TGRefreshOC)
@property (strong, nonatomic) TGRefreshOC *tg_header;
@end
