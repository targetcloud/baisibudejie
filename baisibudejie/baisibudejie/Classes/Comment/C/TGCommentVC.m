//
//  TGCommentVC.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/23.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGCommentVC.h"
#import "TGCommentHeaderFooterV.h"
#import "TGCommentCell.h"
#import "TGTopicCell.h"
#import "TGTopicM.h"
#import "TGCommentM.h"
#import <MJExtension.h>
#import <MJRefresh.h>
#import <AFNetworking.h>

@interface TGCommentVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (weak ,nonatomic) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSArray<TGCommentM *> *hotestComments;
@property (nonatomic, strong) NSMutableArray<TGCommentM *> *latestComments;
@property (nonatomic, strong) TGCommentM *savedTopCmt;

@end

static NSString *const commentID = @"commnet";
static NSString *const headID = @"head";

@implementation TGCommentVC
{
    NSInteger _page;
}

- (AFHTTPSessionManager *)manager{
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBase];
    [self setupTableView];
    [self setupRefresh];
    [self setupHeadView];
}

-(void)setupBase{
    self.navigationItem.title = @"评论";
    self.tableV.dataSource = self;
    self.tableV.delegate = self;
//    self.tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(KeyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

-(void)setupTableView{
    [self.tableV registerNib:[UINib nibWithNibName:NSStringFromClass([TGCommentCell class]) bundle:nil] forCellReuseIdentifier:commentID];
    self.tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableV.backgroundColor = [TGGrayColor(244) colorWithAlphaComponent:0.3];
    self.tableV.rowHeight = UITableViewAutomaticDimension;
    self.tableV.estimatedRowHeight = 44;
}

-(void)setupRefresh{
    self.tableV.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewComment)];
    self.tableV.mj_header.automaticallyChangeAlpha = YES;
    [self.tableV.mj_header beginRefreshing];
    self.tableV.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreComment)];
    self.tableV.mj_footer.hidden = YES;
}

-(void)setupHeadView{
    self.savedTopCmt = self.topic.top_cmt;
    self.topic.top_cmt = nil;
    [self.topic setValue:@0 forKey:@"cellHeight" ];
    [self.tableV registerClass:[TGCommentHeaderFooterV class] forHeaderFooterViewReuseIdentifier:headID];
    self.tableV.sectionHeaderHeight = [UIFont systemFontOfSize:13].lineHeight + Margin;
    
    UIView *headV = [[UIView alloc] init];
    TGTopicCell *topicCell = [TGTopicCell viewFromXIB];
    topicCell.backgroundColor = TGGrayColor(255);
    topicCell.topic = self.topic;
    topicCell.frame = CGRectMake(0, 0, ScreenW, self.topic.cellHeight);
    headV.height = topicCell.height;
    [headV addSubview:topicCell];
    self.tableV.tableHeaderView = headV;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.tableV.contentInset = UIEdgeInsetsMake(NavMaxY, 0, 0, 0);
}

-(void)loadNewComment{
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"a"] = @"dataList";
    parameters[@"c"] = @"comment";
    parameters[@"data_id"] = self.topic.ID;
    parameters[@"hot"] = @1;
    __weak typeof(self) weakSelf = self;
    [self.manager GET:CommonURL parameters:parameters progress:nil  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            [weakSelf.tableV.mj_header endRefreshing];
            return;
        }
        weakSelf.latestComments = [TGCommentM mj_objectArrayWithKeyValuesArray:responseObject[@"data"]];
        weakSelf.hotestComments = [TGCommentM mj_objectArrayWithKeyValuesArray:responseObject[@"hot"]];
        _page = 1;
        [weakSelf.tableV reloadData];
        [weakSelf.tableV.mj_header endRefreshing];
        
        NSInteger total = [responseObject[@"total"] intValue];
        weakSelf.tableV.mj_footer.hidden = weakSelf.latestComments.count >= total;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf.tableV.mj_header endRefreshing];
    }];
}

-(void)loadMoreComment{
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"a"] = @"dataList";
    parameters[@"c"] = @"comment";
    parameters[@"data_id"] = self.topic.ID;
    parameters[@"lastcid"] = self.latestComments.lastObject.ID;
    parameters[@"page"] = @(++_page);
    __weak typeof(self) weakSelf = self;
    [self.manager GET:CommonURL parameters:parameters progress:nil  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            _page--;
            [weakSelf.tableV.mj_footer endRefreshing];
            return;
        }
        NSArray *moreComment = [TGCommentM mj_objectArrayWithKeyValuesArray:responseObject[@"data"]];
        [weakSelf.latestComments addObjectsFromArray:moreComment];
        [weakSelf.tableV reloadData];
        [weakSelf.tableV.mj_footer endRefreshing];
        
        NSInteger total = [responseObject[@"total"] integerValue];
        TGLog(@"total %zd, count %zd",total,weakSelf.latestComments.count)
        weakSelf.tableV.mj_footer.hidden = weakSelf.latestComments.count >=  total;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        _page--;
        [weakSelf.tableV.mj_footer endRefreshing];
    }];
}

-(void)KeyboardWillChangeFrame:(NSNotification *)not{
    CGFloat kbY = [not.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue].origin.y;
    self.bottomMargin.constant = ScreenH - kbY;
    CGFloat duration = [not.userInfo [UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.manager invalidateSessionCancelingTasks:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.topic.top_cmt = (self.hotestComments.count>0) ? self.hotestComments.firstObject : self.savedTopCmt;
    [self.topic setValue:@0 forKey:@"cellHeight"];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark - tableview代理和数据源
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    TGCommentHeaderFooterV *headView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headID];
    headView.textLabel.text = (section == 0 && self.hotestComments.count) ? @"最热评论" : @"最新评论";
    return headView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    self.tableV.mj_footer.hidden = self.latestComments.count == 0;
    return (self.hotestComments.count) ? 2 : ((self.latestComments.count) ? 1 : 0);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  (section == 0 && self.hotestComments.count) ? self.hotestComments.count : self.latestComments.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TGCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:commentID forIndexPath:indexPath];
    cell.comment = (indexPath.section == 0 && self.hotestComments.count) ? _hotestComments[indexPath.row] : _latestComments[indexPath.row];
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 0.001f;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        [menu setMenuVisible:NO animated:YES];
    } else {
        TGCommentCell *cell = (TGCommentCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell becomeFirstResponder];
        UIMenuItem *ding = [[UIMenuItem alloc] initWithTitle:@"顶" action:@selector(ding:)];
        UIMenuItem *replay = [[UIMenuItem alloc] initWithTitle:@"回复" action:@selector(replay:)];
        UIMenuItem *report = [[UIMenuItem alloc] initWithTitle:@"举报" action:@selector(report:)];
        menu.menuItems = @[ding, replay, report];
        CGRect rect = CGRectMake(0, cell.height * 0.5, cell.width, cell.height * 0.5);
        [menu setTargetRect:rect inView:cell];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (void)ding:(UIMenuController *)menu{
    NSIndexPath *indexPath = [self.tableV indexPathForSelectedRow];
    TGLog(@"%s %@", __func__, (indexPath.section == 0 && self.hotestComments.count) ? _hotestComments[indexPath.row].content : _latestComments[indexPath.row].content)
}

- (void)replay:(UIMenuController *)menu{
    NSIndexPath *indexPath = [self.tableV indexPathForSelectedRow];
    TGLog(@"%s %@", __func__, (indexPath.section == 0 && self.hotestComments.count) ? _hotestComments[indexPath.row].content : _latestComments[indexPath.row].content)
}

- (void)report:(UIMenuController *)menu{
    NSIndexPath *indexPath = [self.tableV indexPathForSelectedRow];
    TGLog(@"%s %@", __func__, (indexPath.section == 0 && self.hotestComments.count) ? _hotestComments[indexPath.row].content : _latestComments[indexPath.row].content)
}

@end
