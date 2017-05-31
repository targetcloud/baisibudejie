//
//  TGJokesVC.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/31.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGJokesVC.h"

@interface TGJokesVC ()

@end

@implementation TGJokesVC

-(NSString *) requesturl :(NSString *) nextpage{
    //http://s.budejie.com/topic/tag-topic/64/hot/bs0315-iphone-4.5.6/0-20.json
    return [NSString stringWithFormat:@"http://s.budejie.com/topic/tag-topic/64/hot/bs0315-iphone-4.5.6/%@-20.json",nextpage];
}

@end
