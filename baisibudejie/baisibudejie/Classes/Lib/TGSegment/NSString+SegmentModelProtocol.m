//
//  NSString+SegmentModelProtocol.m
//  TGSegment
//
//  Created by targetcloud on 2017/4/18.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "NSString+SegmentModelProtocol.h"

@implementation NSString (SegmentModelProtocol)
- (NSInteger)segID {
    return -1;
}

- (NSString *)segContent {
    return self;
}
@end
