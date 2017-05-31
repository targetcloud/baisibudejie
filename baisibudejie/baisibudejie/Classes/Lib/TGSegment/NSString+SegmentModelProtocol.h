//
//  NSString+SegmentModelProtocol.h
//  TGSegment
//
//  Created by targetcloud on 2017/4/18.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGSegmentModelProtocol.h"

@interface NSString (SegmentModelProtocol)<TGSegmentModelProtocol>
- (NSInteger)segID;
- (NSString *)segContent;
@end
