//
//  TGFileTool.h
//  baisibudejie
//
//  Created by targetcloud on 2017/3/8.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGFileTool : NSObject
+ (void)getFileSize:(NSString *)directoryPath completion:(void(^)(NSInteger))completion;
+ (void)removeDirectoryPath:(NSString *)directoryPath;
@end
