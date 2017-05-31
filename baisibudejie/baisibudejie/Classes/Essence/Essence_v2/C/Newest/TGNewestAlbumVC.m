//
//  TGNewestAlbumVC.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/31.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGNewestAlbumVC.h"

@interface TGNewestAlbumVC ()

@end

@implementation TGNewestAlbumVC

-(NSString *) requesturl :(NSString *) nextpage{
    //http://s.budejie.com/topic/tag-topic/50471/new/bs0315-iphone-4.5.6/0-20.json
    return [NSString stringWithFormat:@"http://s.budejie.com/topic/tag-topic/50471/new/bs0315-iphone-4.5.6/%@-20.json",nextpage];
}

@end
