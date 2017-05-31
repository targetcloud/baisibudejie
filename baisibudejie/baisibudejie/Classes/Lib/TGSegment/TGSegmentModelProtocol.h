//
//  TGSegmentModelProtocol.h
//  TGSegment
//
//  Created by targetcloud on 2017/4/18.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TGSegmentModelProtocol <NSObject>
@property (nonatomic, assign, readonly) NSInteger segID;
@property (nonatomic, copy, readonly) NSString *segContent;
@end
