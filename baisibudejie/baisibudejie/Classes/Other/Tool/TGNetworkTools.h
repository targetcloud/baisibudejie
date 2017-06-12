//
//  TGNetworkTools.h
//  baisibudejie
//
//  Created by targetcloud on 2017/6/13.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

typedef enum : NSUInteger {
    GET,
    POST,
} HTTPMethod;

@interface TGNetworkTools : AFHTTPSessionManager
+ (instancetype) sharedTools;
- (void) request:(HTTPMethod)method urlString:(NSString *)urlString  parameters:(id)parameters finished:(void(^)(id ,NSError *))finished;
@end
