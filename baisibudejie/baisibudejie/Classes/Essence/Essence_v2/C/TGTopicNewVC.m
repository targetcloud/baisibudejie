//
//  TGTopicNewVC.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/30.
//  Copyright © 2017年 targetcloud. All rights reserved.
//  Blog http://blog.csdn.net/callzjy
//  Mail targetcloud@163.com
//  Github https://github.com/targetcloud

#import "TGTopicNewVC.h"
#import "TGTopicNewM.h"
#import "TGTopicNewCell.h"
#import "TGCommentNewVC.h"
#import "TGCarouselImageView.h"
#import "TGWebVC.h"
//#import <AFNetworking.h>
#import <SVProgressHUD.h>
#import <MJExtension.h>
#import <SDImageCache.h>
#import <MJRefresh.h>
#import "TGNetworkTools.h"

static NSString * const TGTopicCellID = @"TGTopicNewCellID";

@interface TGTopicNewVC ()
@property (nonatomic, strong) NSMutableArray<TGTopicNewM *> *topics;
//@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSMutableDictionary *params;
@property (nonatomic, assign) NSInteger lastSelectedIndex;
@end

@implementation TGTopicNewVC
{
    CGFloat _contentOffsetY;//上次的offset
    CGFloat _contentOffsetSpeed;//与上次的滚差，用于判断速度
    NSString * _np;
}

- (NSMutableArray<TGTopicNewM *> *)topics{
    if(!_topics){
        _topics = [NSMutableArray array];
    }
    return _topics;
}

-(NSString *) requesturl :(NSString *) nextpage{
    return [NSString stringWithFormat:@"http://s.budejie.com/topic/list/jingxuan/1/bs0315-iphone-4.5.6/%@-20.json",nextpage];
}

-(BOOL) showAD{
    return NO;
}

//- (AFHTTPSessionManager *)manager{
//    if (!_manager) {
//        _manager = [AFHTTPSessionManager manager];
//    }
//    return _manager;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    _np = @"0";
    self.view.backgroundColor = TGGrayColor(206);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TGTopicNewCell class]) bundle:nil] forCellReuseIdentifier:TGTopicCellID];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabBarButtonDidRepeatClick) name:TabBarButtonDidRepeatClickNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(titleButtonDidRepeatClick) name:TitleButtonDidRepeatClickNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustTableViewContentInsetWithHidden) name:NavigationBarHiddenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustTableViewContentInsetWithShow) name:NavigationBarShowNotification object:nil];
    
    [self setupRefresh];
}

-(void)adjustTableViewContentInsetWithHidden{
    if (self.view.superview.tag != 9999){
        self.tableView.contentInset = UIEdgeInsetsMake( NavMaxY , 0, TabBarH, 0);
    }
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
}

-(void) adjustTableViewContentInsetWithShow{
    if (self.view.superview.tag != 9999){
        self.tableView.contentInset = UIEdgeInsetsMake( NavMaxY + TitleVH, 0, TabBarH, 0);
    }
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[self.manager invalidateSessionCancelingTasks:YES];
    //[[TGNetworkTools sharedTools] invalidateSessionCancelingTasks:YES];
}

- (void)tabBarButtonDidRepeatClick{
    if (self.view.window == nil) return;
    if (self.tableView.scrollsToTop == NO) return;
    if (self.lastSelectedIndex == self.tabBarController.selectedIndex
        //&& self.tabBarController.selectedViewController == self.navigationController
        && self.view.isShowingOnKeyWindow) {
        TGFunc
        [self.tableView.mj_header beginRefreshing];
    }
    self.lastSelectedIndex = self.tabBarController.selectedIndex;
}

- (void)titleButtonDidRepeatClick{
    [self tabBarButtonDidRepeatClick];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    self.tableView.mj_footer.hidden = (self.topics.count == 0);
    return self.topics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TGTopicNewCell *cell = [tableView dequeueReusableCellWithIdentifier:TGTopicCellID forIndexPath:indexPath];
    cell.topic = self.topics[indexPath.row];
    //传入block，用于展开收缩
    __weak typeof(self)weakSelf = self;
    __weak typeof(cell)weakCell = cell;
    cell.block = ^ {
        weakCell.topic = weakSelf.topics[indexPath.row];
        [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    };
    [cell setCommentBlock:^(NSString * topicId){
        TGCommentNewVC *commentVc = [[TGCommentNewVC alloc] init];
        [weakSelf.topics[indexPath.row] setShowAllWithoutComment:YES];
        commentVc.topic = weakSelf.topics[indexPath.row];
        [weakSelf.navigationController pushViewController:commentVc animated:YES];
    }];
    [cell setUpBlock:^(NSString * topicId){
        
    }];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.topics[indexPath.row].cellHeight;
}

- (void)setupRefresh{
    if ([self showAD]){
        NSArray *imageArray = @[@"http://img.spriteapp.cn/spritead/20170531/185026958423.jpg",
                                @"http://img.spriteapp.cn/spritead/20170531/185139989275.jpg",
                                @"http://img.spriteapp.cn/spritead/20170531/185540702503.jpg",
                                @"http://img.spriteapp.cn/spritead/20170531/185049847752.jpg",
                                @"http://img.spriteapp.cn/spritead/20170531/185217240322.jpg"];
        NSMutableArray *describeArray = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < imageArray.count; i++) {
            NSString *tempDesc = [NSString stringWithFormat:@"Image Description %zd", i];
            [describeArray addObject:tempDesc];
        }
        NSArray * urlArray = @[
                               @"https://github.com/targetcloud",
                               @"http://weibo.com/targetcloud",
                               @"http://blog.csdn.net/callzjy",
                               @"http://www.jianshu.com/p/718a12502887",
                               @"https://www.cnblogs.com/targetcloud"
                               ];
        TGCarouselImageView *carouselIV = [TGCarouselImageView tg_carouselImageViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200) imageArrary:imageArray describeArray:nil placeholderImage:[UIImage imageNamed:@"adph3.jpg"] block:^(NSInteger index) {
            //TGLog(@"index: %zd", index)
            TGWebVC *webVc = [[TGWebVC alloc] init];
            webVc.url = [NSURL URLWithString:urlArray[index]];
            [self.navigationController pushViewController:webVc animated:YES];
        }];
        
        UIImage * currentPageIndicatorImage = [UIImage imageWithColor:[UIColor redColor] andRect:CGRectMake(0, 0, 10, 2)];
        UIImage * pageIndicatorImage = [UIImage imageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.1 ] andRect:CGRectMake(0, 0, 10, 2)];
        carouselIV.currentPageIndicatorImage = currentPageIndicatorImage;
        carouselIV.pageIndicatorImage = pageIndicatorImage;
        
        self.tableView.tableHeaderView = carouselIV;
    }
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewTopics)];
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    [self.tableView.mj_header beginRefreshing];
    
    //类似下拉刷新效果
    //self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTopics)];
    
    //类似静默加载效果
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTopics)];
}

- (void)loadNewTopics{
    [self.tableView.mj_footer endRefreshing];
    //[self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    self.params = parameters;
    
    TGNetworkTools *tools = [TGNetworkTools sharedTools];
    //[tools.tasks makeObjectsPerformSelector:@selector(cancel)];
    [tools request:GET urlString:[self requesturl:@"0"] parameters:parameters finished:^(id responseObject, NSError * error) {
        if (error != nil) {
            if (self.params != parameters) return ;
            if (error.code != NSURLErrorCancelled) { // 并非是取消任务导致的error，其他网络问题导致的error
                [SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试！"];
            }
            [self.tableView.mj_header endRefreshing];
            return;
        }
        if (self.params != parameters) return ;
        //AFNWriteToPlist(new_topics)
        _np = responseObject[@"info"][@"np"];
        self.topics = [TGTopicNewM mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
        //过滤html
        [self.topics enumerateObjectsUsingBlock:^(TGTopicNewM * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.type isEqualToString:@"html"]){
                [self.topics removeObject:obj];
            }
        }];
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    }];
    
//    [self.manager GET:[self requesturl:@"0"] parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
//        if (self.params != parameters) return ;
//        AFNWriteToPlist(new_topics)
//        _np = responseObject[@"info"][@"np"];
//        self.topics = [TGTopicNewM mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
//        //过滤html
//        [self.topics enumerateObjectsUsingBlock:^(TGTopicNewM * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([obj.type isEqualToString:@"html"]){
//                [self.topics removeObject:obj];
//            }
//        }];
//        [self.tableView reloadData];
//        [self.tableView.mj_header endRefreshing];
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        if (self.params != parameters) return ;
//        if (error.code != NSURLErrorCancelled) { // 并非是取消任务导致的error，其他网络问题导致的error
//            [SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试！"];
//        }
//        [self.tableView.mj_header endRefreshing];
//    }];
}

- (void)loadMoreTopics{
    [self.tableView.mj_header endRefreshing];
    //[self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    self.params = parameters;
    
    TGNetworkTools *tools = [TGNetworkTools sharedTools];
    //[tools.tasks makeObjectsPerformSelector:@selector(cancel)];
    [tools request:GET urlString:[self requesturl:_np] parameters:parameters finished:^(id responseObject, NSError * error) {
        if (error != nil) {
            if (self.params != parameters) return ;
            if (error.code != NSURLErrorCancelled) { // 并非是取消任务导致的error，其他网络问题导致的error
                [SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试！"];
            }
            [self.tableView.mj_footer endRefreshing];
            return;
        }
        if (self.params != parameters) return ;
        _np = responseObject[@"info"][@"np"];
        NSMutableArray *moreTopics = [TGTopicNewM mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
        //过滤html
        [moreTopics enumerateObjectsUsingBlock:^(TGTopicNewM * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.type isEqualToString:@"html"]){
                [moreTopics removeObject:obj];
            }
        }];
        [self.topics addObjectsFromArray:moreTopics];
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];
    }];
//    
//    [self.manager GET:[self requesturl:_np] parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
//        if (self.params != parameters) return ;
//        _np = responseObject[@"info"][@"np"];
//        NSMutableArray *moreTopics = [TGTopicNewM mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
//        //过滤html
//        [moreTopics enumerateObjectsUsingBlock:^(TGTopicNewM * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([obj.type isEqualToString:@"html"]){
//                [moreTopics removeObject:obj];
//            }
//        }];
//        [self.topics addObjectsFromArray:moreTopics];
//        [self.tableView reloadData];
//        [self.tableView.mj_footer endRefreshing];
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        if (self.params != parameters) return ;
//        if (error.code != NSURLErrorCancelled) { // 并非是取消任务导致的error，其他网络问题导致的error
//            [SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试！"];
//        }
//        [self.tableView.mj_footer endRefreshing];
//    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{//只会触发上拉加载更多
    if (scrollView.contentOffset.y > _contentOffsetY){//上滚
        //TGLog(@"up %f",scrollView.contentOffset.y);
        if (scrollView.contentOffset.y > 0){
            //隐藏，放入nav
            //通知形式
            //TGLog(@"我要隐藏了～～～～～～～～～～～～ %f",scrollView.contentOffset.y);
            if((scrollView.contentOffset.y - _contentOffsetY) > _contentOffsetSpeed && _contentOffsetSpeed>20){//速度超过20隐藏
                //TGLog(@"~~~~~~~~~~~~~~~~~~~~~%f %f",scrollView.contentOffset.y - _contentOffsetY,_contentOffsetSpeed);//滚速递减则不再发通知
                [[NSNotificationCenter defaultCenter] postNotificationName:NavigationBarHiddenNotification object:nil userInfo:nil];
            }
            _contentOffsetSpeed = scrollView.contentOffset.y - _contentOffsetY;
        }
    }else{
        //显示，回归原位
        //通知形式
        //TGLog(@"dwon %f",scrollView.contentOffset.y);
        if (scrollView.contentOffset.y > 0){
            //TGLog(@"我要显示了^^^^^^^^^^^^^^^^^^^^ %f",scrollView.contentOffset.y);
            if (_contentOffsetY - scrollView.contentOffset.y > _contentOffsetSpeed && _contentOffsetSpeed>20){//速度超过20显示
                //TGLog(@"^^^^^^^^^^^^^^^^^^^^^^^%f %f",_contentOffsetY - scrollView.contentOffset.y,_contentOffsetSpeed);
                [[NSNotificationCenter defaultCenter] postNotificationName:NavigationBarShowNotification object:nil userInfo:nil];
            }
            _contentOffsetSpeed = _contentOffsetY - scrollView.contentOffset.y;
        }else if (fabs(scrollView.contentOffset.y) > NavMaxY && fabs(scrollView.contentOffset.y) < NavMaxY+TitleVH){
            //TGLog(@"我要显示了^^^^^^^^^^^^^^^^^^^^ %f",scrollView.contentOffset.y);
            [[NSNotificationCenter defaultCenter] postNotificationName:NavigationBarShowNotification object:nil userInfo:nil];
        }
    }
    _contentOffsetY = scrollView.contentOffset.y;
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [[SDImageCache sharedImageCache] clearMemory];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TGCommentNewVC *commentVc = [[TGCommentNewVC alloc] init];
    [self.topics[indexPath.row] setShowAllWithoutComment:YES];
    commentVc.topic = self.topics[indexPath.row];
    [self.navigationController pushViewController:commentVc animated:YES];
}
@end
