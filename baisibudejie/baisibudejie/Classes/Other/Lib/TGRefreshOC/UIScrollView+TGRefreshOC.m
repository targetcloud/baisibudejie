//
//  UIScrollView+TGRefreshOC.m
//  TGRefreshOC
//
//  Created by targetcloud on 2017/6/20.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "UIScrollView+TGRefreshOC.h"
#import <objc/runtime.h>

@implementation UIScrollView (TGRefreshOC)

static const char TGRefreshOCHeaderKey = '\0';

- (void)setTg_header:(TGRefreshOC *)tg_header{
    if (tg_header != self.tg_header) {
        [self.tg_header removeFromSuperview];
        [self insertSubview:tg_header atIndex:0];
        [self willChangeValueForKey:@"tg_header"];
        objc_setAssociatedObject(self, &TGRefreshOCHeaderKey,tg_header, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"tg_header"];
    }
}

- (TGRefreshOC *)tg_header{
    return objc_getAssociatedObject(self, &TGRefreshOCHeaderKey);
}

@end
