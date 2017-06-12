//
//  TGSubTagVC.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/6.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGSubTagVC.h"
#import "TGSubTagM.h"
#import "TGSubTagCell.h"
#import "TGNetworkTools.h"
#import <MJExtension/MJExtension.h>
#import <SVProgressHUD/SVProgressHUD.h>

static NSString * const ID = @"cell";

@interface TGSubTagVC ()
@property (nonatomic, strong) NSArray *subTags;
@end

@implementation TGSubTagVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    [self.tableView registerNib:[UINib nibWithNibName:@"TGSubTagCell" bundle:nil] forCellReuseIdentifier:ID];
    self.title = @"推荐标签";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = TGColor(220, 220, 221);
    [SVProgressHUD showWithStatus:@"正在加载ing....."];
    [self setupRefresh];
}

- (void)setupRefresh{
    
}

- (void)loadData{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"a"] = @"tag_recommend";
    parameters[@"action"] = @"sub";
    parameters[@"c"] = @"topic";
    
    [[TGNetworkTools sharedTools] request:GET urlString:CommonURL parameters:parameters finished:^(id responseObject, NSError * error) {
        if (error != nil) {
            [SVProgressHUD dismiss];
            return;
        }
        NSLog(@"%@",responseObject);
        [SVProgressHUD dismiss];
        _subTags = [TGSubTagM mj_objectArrayWithKeyValuesArray:responseObject];
        [self.tableView reloadData];
    }];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
    [[TGNetworkTools sharedTools].tasks makeObjectsPerformSelector:@selector(cancel)];//取消之前的请求
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.subTags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TGSubTagCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    cell.item = self.subTags[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

@end
