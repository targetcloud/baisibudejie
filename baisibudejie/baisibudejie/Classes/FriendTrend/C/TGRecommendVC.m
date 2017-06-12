//
//  TGRecommendVC.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/16.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGRecommendVC.h"
//#import <AFNetworking.h>
#import "TGNetworkTools.h"
#import <SVProgressHUD.h>
#import <MJExtension.h>
#import <MJRefresh.h>
#import "TGRecommendCategoryCell.h"
#import "TGRecommendUserCell.h"
#import "TGRecommendCategoryM.h"
#import "TGRecommendUserM.h"

@interface TGRecommendVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *categories;
@property (weak, nonatomic) IBOutlet UITableView *categoryTableV;
@property (weak, nonatomic) IBOutlet UITableView *userTableV;
@property (nonatomic, strong) NSMutableDictionary *params;
//@property (nonatomic, strong) AFHTTPSessionManager *manager;
@end

static NSString * const TGCategoryId = @"category";
static NSString * const TGUserId = @"user";

@implementation TGRecommendVC

//- (AFHTTPSessionManager *)manager{
//    if (!_manager) {
//        _manager = [AFHTTPSessionManager manager];
//    }
//    return _manager;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"推荐关注";
    [self setupTableView];
    [self setupRefresh];
    [self loadCategories];
}

- (void)loadCategories{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    //[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"a"] = @"category";
    params[@"c"] = @"subscribe";
    
    TGNetworkTools *tools = [TGNetworkTools sharedTools];
    [tools request:GET urlString:@"http://api.budejie.com/api/api_open.php" parameters:params finished:^(id responseObject, NSError * error) {
        if (error != nil) {
            [SVProgressHUD showErrorWithStatus:@"加载推荐信息失败!"];
            return;
        }
        [SVProgressHUD dismiss];
        self.categories = [TGRecommendCategoryM mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
        [self.categoryTableV reloadData];
        [self.categoryTableV selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        [self.userTableV.mj_header beginRefreshing];
    }];
    
//    [self.manager GET:@"http://api.budejie.com/api/api_open.php" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
//        [SVProgressHUD dismiss];
//        self.categories = [TGRecommendCategoryM mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
//        [self.categoryTableV reloadData];
//        [self.categoryTableV selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
//        [self.userTableV.mj_header beginRefreshing];
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        [SVProgressHUD showErrorWithStatus:@"加载推荐信息失败!"];
//    }];
}

- (void)setupTableView{
    [self.categoryTableV registerNib:[UINib nibWithNibName:NSStringFromClass([TGRecommendCategoryCell class]) bundle:nil] forCellReuseIdentifier:TGCategoryId];
    [self.userTableV registerNib:[UINib nibWithNibName:NSStringFromClass([TGRecommendUserCell class]) bundle:nil] forCellReuseIdentifier:TGUserId];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.categoryTableV.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.userTableV.contentInset = self.categoryTableV.contentInset;
    self.userTableV.rowHeight = 70;
}

- (void)setupRefresh{
    self.userTableV.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewUsers)];
    self.userTableV.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreUsers)];
    self.userTableV.mj_header.automaticallyChangeAlpha = YES;
    self.userTableV.mj_footer.hidden = YES;
}

- (void)loadNewUsers{
    [self.userTableV.mj_footer endRefreshing];
    //[self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    TGRecommendCategoryM *rc = self.categories[self.categoryTableV.indexPathForSelectedRow.row];
    rc.currentPage = 1;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"a"] = @"list";
    params[@"c"] = @"subscribe";
    params[@"category_id"] = @(rc.id);
    params[@"page"] = @(rc.currentPage);
    self.params = params;
    
    TGNetworkTools *tools = [TGNetworkTools sharedTools];
    [tools.tasks makeObjectsPerformSelector:@selector(cancel)];
    [tools request:GET urlString:@"http://api.budejie.com/api/api_open.php" parameters:params finished:^(id responseObject, NSError * error) {
        if (error != nil) {
            if (self.params != params) return;
            [SVProgressHUD showErrorWithStatus:@"加载用户数据失败"];
            [self.userTableV.mj_header endRefreshing];
            return;
        }
        NSArray *users = [TGRecommendUserM mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
        [rc.users removeAllObjects];
        [rc.users addObjectsFromArray:users];
        rc.total = [responseObject[@"total"] integerValue];
        if (self.params != params) return;
        [self.userTableV reloadData];
        [self.userTableV.mj_header endRefreshing];
        [self checkFooterState];
    }];
    
//    [self.manager GET:@"http://api.budejie.com/api/api_open.php" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
//        NSArray *users = [TGRecommendUserM mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
//        [rc.users removeAllObjects];
//        [rc.users addObjectsFromArray:users];
//        rc.total = [responseObject[@"total"] integerValue];
//        if (self.params != params) return;
//        [self.userTableV reloadData];
//        [self.userTableV.mj_header endRefreshing];
//        [self checkFooterState];
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        if (self.params != params) return;
//        [SVProgressHUD showErrorWithStatus:@"加载用户数据失败"];
//        [self.userTableV.mj_header endRefreshing];
//    }];
}

- (void)loadMoreUsers{
    [self.userTableV.mj_header endRefreshing];
    //[self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    TGRecommendCategoryM *category = self.categories[self.categoryTableV.indexPathForSelectedRow.row];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"a"] = @"list";
    params[@"c"] = @"subscribe";
    params[@"category_id"] = @(category.id);
    params[@"page"] = @(++category.currentPage);
    self.params = params;
    
    TGNetworkTools *tools = [TGNetworkTools sharedTools];
    [tools.tasks makeObjectsPerformSelector:@selector(cancel)];
    [tools request:GET urlString:@"http://api.budejie.com/api/api_open.php" parameters:params finished:^(id responseObject, NSError * error) {
        if (error != nil) {
            if (self.params != params) return;
            category.currentPage--;
            [SVProgressHUD showErrorWithStatus:@"加载用户数据失败"];
            [self.userTableV.mj_footer endRefreshing];
            return;
        }
        NSArray *users = [TGRecommendUserM mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
        [category.users addObjectsFromArray:users];
        if (self.params != params) return;
        [self.userTableV reloadData];
        [self checkFooterState];
    }];
    
//    [self.manager GET:@"http://api.budejie.com/api/api_open.php" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
//        NSArray *users = [TGRecommendUserM mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
//        [category.users addObjectsFromArray:users];
//        if (self.params != params) return;
//        [self.userTableV reloadData];
//        [self checkFooterState];
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        if (self.params != params) return;
//        category.currentPage--;
//        [SVProgressHUD showErrorWithStatus:@"加载用户数据失败"];
//        [self.userTableV.mj_footer endRefreshing];
//    }];
}

- (void)checkFooterState{
    TGRecommendCategoryM *rc = self.categories[self.categoryTableV.indexPathForSelectedRow.row];
    self.userTableV.mj_footer.hidden = (rc.users.count == 0);
    if (rc.users.count == rc.total) {
        [self.userTableV.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.userTableV.mj_footer endRefreshing];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.categoryTableV) return self.categories.count;
    [self checkFooterState];
    return [self.categories[self.categoryTableV.indexPathForSelectedRow.row] users].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.categoryTableV) {
        TGRecommendCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:TGCategoryId];
        cell.category = self.categories[indexPath.row];
        return cell;
    } else {
        TGRecommendUserCell *cell = [tableView dequeueReusableCellWithIdentifier:TGUserId];
        cell.user = [self.categories[self.categoryTableV.indexPathForSelectedRow.row] users][indexPath.row];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.categoryTableV) {
        [self.userTableV.mj_header endRefreshing];
        [self.userTableV.mj_footer endRefreshing];
        
        TGRecommendCategoryM *rc = self.categories[indexPath.row];
        if (rc.users.count) {
            [self.userTableV reloadData];
        } else {
            [self.userTableV reloadData];
            [self.userTableV.mj_header beginRefreshing];
        }
    }
}

- (void)dealloc{
    //[self.manager.operationQueue cancelAllOperations];
     [[TGNetworkTools sharedTools].operationQueue cancelAllOperations];
}
@end
