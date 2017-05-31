//
//  NSDate+calendar.h
//  baisibudejie
//
//  Created by targetcloud on 2017/5/18.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (calendar)
- (NSDateComponents *)deltaFrom:(NSDate *)from;
- (BOOL)isThisYear;
- (BOOL)isToday;
- (BOOL)isYesterday;
@end
