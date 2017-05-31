//
//  TGFileTool.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/8.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGFileTool.h"

@implementation TGFileTool
+ (void)removeDirectoryPath:(NSString *)directoryPath{
    NSFileManager *mgr = [NSFileManager defaultManager];
    BOOL isDirectory;
    BOOL isExist = [mgr fileExistsAtPath:directoryPath isDirectory:&isDirectory];
    if (!isExist || !isDirectory) {
        NSException *excp = [NSException exceptionWithName:@"pathError" reason:@"请传入的是文件夹路径,并且路径要存在" userInfo:nil];
        [excp raise];
    }
    NSArray *subPaths = [mgr contentsOfDirectoryAtPath:directoryPath error:nil];
    for (NSString *subPath in subPaths) {
        NSString *filePath = [directoryPath stringByAppendingPathComponent:subPath];
        [mgr removeItemAtPath:filePath error:nil];
    }
}

+ (void)getFileSize:(NSString *)directoryPath completion:(void(^)(NSInteger))completion{
    NSFileManager *mgr = [NSFileManager defaultManager];
    BOOL isDirectory;
    BOOL isExist = [mgr fileExistsAtPath:directoryPath isDirectory:&isDirectory];
    if (!isExist || !isDirectory) {
        NSException *excp = [NSException exceptionWithName:@"pathError" reason:@"请传入的是文件夹路径,并且路径要存在" userInfo:nil];
        [excp raise];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *subPaths = [mgr subpathsAtPath:directoryPath];
        NSInteger totalSize = 0;
        for (NSString *subPath in subPaths) {
            NSString *filePath = [directoryPath stringByAppendingPathComponent:subPath];
            if ([filePath containsString:@".DS"]) continue;//隐藏文件
            BOOL isDirectory;
            BOOL isExist = [mgr fileExistsAtPath:filePath isDirectory:&isDirectory];
            if (!isExist || isDirectory) continue;//非文件（是目录） 或 文件不存在
            totalSize += [[mgr attributesOfItemAtPath:filePath error:nil] fileSize];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(totalSize);
            }
        });
    });
}
@end
