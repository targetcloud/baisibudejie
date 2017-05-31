//
//  TGTopicVC.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/8.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGTopicVC.h"
#import "TGTopicM.h"
#import "TGTopicCell.h"
#import "TGCommentVC.h"
#import "TGNewVC.h"
#import <AFNetworking.h>
#import <SVProgressHUD.h>
#import <MJExtension.h>
#import <SDImageCache.h>
#import <MJRefresh.h>

static NSString * const TGTopicCellID = @"TGTopicCellID";

@interface TGTopicVC ()
@property (nonatomic, copy) NSString *maxtime;
@property (nonatomic, strong) NSMutableArray<TGTopicM *> *topics;
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSMutableDictionary *params;
@property (nonatomic, assign) NSInteger lastSelectedIndex;

/*
@property (nonatomic, weak) UIView *header;
@property (nonatomic, weak) UILabel *headerLabel;
@property (nonatomic, assign, getter=isHeaderRefreshing) BOOL headerRefreshing;

@property (nonatomic, weak) UIView *footer;
@property (nonatomic, weak) UILabel *footerLabel;
@property (nonatomic, assign, getter=isFooterRefreshing) BOOL footerRefreshing;
 */
@end

@implementation TGTopicVC
{
    CGFloat _contentOffsetY;//上次的offset
    CGFloat _contentOffsetSpeed;//与上次的滚差，用于判断速度
}

- (NSMutableArray<TGTopicM *> *)topics{
    if(!_topics){
        _topics = [NSMutableArray array];
    }
    return _topics;
}

-(TGTopicType) type{
//    return TGTopicTypeVoice;
    return 0;
}

- (AFHTTPSessionManager *)manager{
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = TGGrayColor(206);//TGRandomColor;
    //全屏cell活动时，头顶需要有内边距，从而可以看到头尾部分，不然没有边距填充，默认开始内容会在导航栏后面和tabbar后面
//    self.tableView.contentInset = UIEdgeInsetsMake( NavMaxY + TitleVH, 0, TabBarH, 0);
//    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.tableView.rowHeight = 200;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TGTopicCell class]) bundle:nil] forCellReuseIdentifier:TGTopicCellID];
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];//一起移除
    [self.manager invalidateSessionCancelingTasks:YES];
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
    // 记录这一次选中的索引
    self.lastSelectedIndex = self.tabBarController.selectedIndex;
}

- (void)titleButtonDidRepeatClick{
    [self tabBarButtonDidRepeatClick];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return arc4random_uniform(20);
    /*
    self.footer.hidden = (self.topics.count == 0);
     */
    self.tableView.mj_footer.hidden = (self.topics.count == 0);
    return self.topics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    /*
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@-%zd", self.class, indexPath.row];
     */
    TGTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:TGTopicCellID];
    cell.topic = self.topics[indexPath.row];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    TGTopicM * topic = self.topics[indexPath.row];
//    return topic.cellHeight;
    
//    return [self.topics[indexPath.row] cellHeight];//没有泛型用 get语法
    return self.topics[indexPath.row].cellHeight;//@property (nonatomic, strong) NSMutableArray<TGTopicM *> *topics;用泛型才可以用点语法
}

- (void)setupRefresh{
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor grayColor];
    label.frame = CGRectMake(0, 0, 0, 50);
    label.textColor = [UIColor whiteColor];
    label.text = @"广告";
    label.textAlignment = NSTextAlignmentCenter;
    self.tableView.tableHeaderView = label;
    
    /*
    UIView *header = [[UIView alloc] init];
    header.frame = CGRectMake(0, - 50, self.tableView.width, 50);
    _header = header;
    [self.tableView addSubview:header];
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.frame = header.bounds;
    headerLabel.backgroundColor = [UIColor lightGrayColor];
    headerLabel.text = @"下拉刷新";
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.font = [UIFont systemFontOfSize:12];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:headerLabel];
    _headerLabel = headerLabel;
    
    // 让header自动进入刷新
    [self headerBeginRefreshing];
    
    UIView *footer = [[UIView alloc] init];
    footer.frame = CGRectMake(0, 0, self.tableView.width, 35);
    _footer = footer;
    UILabel *footerLabel = [[UILabel alloc] init];
    footerLabel.frame = footer.bounds;
    footerLabel.backgroundColor = [UIColor lightGrayColor];
    footerLabel.text = @"上拉加载更多";
    footerLabel.textColor = [UIColor whiteColor];
    footerLabel.font = [UIFont systemFontOfSize:12];
    footerLabel.textAlignment = NSTextAlignmentCenter;
    [footer addSubview:footerLabel];
    _footerLabel = footerLabel;
    self.tableView.tableFooterView = footer;
     */
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewTopics)];
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    [self.tableView.mj_header beginRefreshing];
    
    //类似下拉刷新效果
    //self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTopics)];
    
    //类似静默加载效果
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTopics)];
    //self.tableView.mj_footer.hidden = YES;
}

- (NSString *)a{
    return [self.parentViewController isKindOfClass:[TGNewVC class]] ? @"newlist" : @"list";
}

- (void)loadNewTopics{
    [self.tableView.mj_footer endRefreshing];
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"a"] = self.a;
    parameters[@"c"] = @"data";
    parameters[@"type"] = @(self.type);
    self.params = parameters;
    [self.manager GET:CommonURL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        if (self.params != parameters) return ;
        AFNWriteToPlist(new_topics)
        _maxtime = responseObject[@"info"][@"maxtime"];
        self.topics = [TGTopicM mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
        [self.tableView reloadData];
        /*
        [self headerEndRefreshing];
         */
        self.page = 0;
        [self.tableView.mj_header endRefreshing];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (self.params != parameters) return ;
        if (error.code != NSURLErrorCancelled) { // 并非是取消任务导致的error，其他网络问题导致的error
            [SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试！"];
        }
        /*
        [self headerEndRefreshing];
         */
        [self.tableView.mj_header endRefreshing];
    }];
}

- (void)loadMoreTopics{
    [self.tableView.mj_header endRefreshing];
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    self.page++;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"a"] = self.a;
    parameters[@"c"] = @"data";
    parameters[@"page"] = @(self.page);
    parameters[@"type"] = @(self.type);
    parameters[@"maxtime"] = _maxtime;
    self.params = parameters;
    [self.manager GET:CommonURL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        if (self.params != parameters) return ;
        _maxtime = responseObject[@"info"][@"maxtime"];
        NSArray *moreTopics = [TGTopicM mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
        [self.topics addObjectsFromArray:moreTopics];
        [self.tableView reloadData];
        /*
        [self footerEndRefreshing];
         */
        [self.tableView.mj_footer endRefreshing];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (self.params != parameters) return ;
        if (error.code != NSURLErrorCancelled) { // 并非是取消任务导致的error，其他网络问题导致的error
            [SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试！"];
        }
        /*
        [self footerEndRefreshing];
         */
        [self.tableView.mj_footer endRefreshing];
        self.page--;
    }];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{//只会触发下拉刷新
    /*
    if (self.tableView.contentOffset.y <= - (self.tableView.contentInset.top + _header.height)) { // header已经完全出现
        [self headerBeginRefreshing];
    }
     */
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{//只会触发上拉加载更多
    /*
    [self dealHeader];
    [self dealFooter];
     */
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

/*
- (void)dealHeader{
    if (self.isHeaderRefreshing) return;
    if (self.tableView.contentOffset.y <= - (self.tableView.contentInset.top + _header.height)) { // header已经完全出现
        _headerLabel.text = @"松开立即刷新";
        _headerLabel.backgroundColor = [UIColor grayColor];
    } else {
        _headerLabel.text = @"下拉刷新";
        _headerLabel.backgroundColor = [UIColor lightGrayColor];
    }
}

- (void)dealFooter{
    if (self.tableView.contentSize.height == 0) return;
    CGFloat ofsetY = self.tableView.contentSize.height + self.tableView.contentInset.bottom - self.tableView.height;
    if (self.tableView.contentOffset.y >= ofsetY && self.tableView.contentOffset.y > - (self.tableView.contentInset.top)) { // footer完全出现，并且是往上拖拽
        [self footerBeginRefreshing];
    }
}

- (void)headerBeginRefreshing{
    if (self.isHeaderRefreshing) return;
    
    _headerLabel.text = @"正在刷新数据...";
    _headerLabel.backgroundColor = [UIColor darkGrayColor];
    _headerRefreshing = YES;
    
    [UIView animateWithDuration:0.25 animations:^{
        UIEdgeInsets inset = self.tableView.contentInset;
        inset.top += _header.height;
        self.tableView.contentInset = inset;
        self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x,  - inset.top);
    }];
    [self loadNewTopics];
}

- (void)headerEndRefreshing{
    _headerRefreshing = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        UIEdgeInsets inset = self.tableView.contentInset;
        inset.top -= _header.height;
        self.tableView.contentInset = inset;
    }];
}

- (void)footerBeginRefreshing{
    if (self.isFooterRefreshing) return;
    
    _footerRefreshing = YES;
    _footerLabel.text = @"正在加载更多数据...";
    _footerLabel.backgroundColor = [UIColor darkGrayColor];
    [self loadMoreTopics];
}

- (void)footerEndRefreshing{
    _footerRefreshing = NO;
    
    _footerLabel.text = @"上拉加载更多";
    _footerLabel.backgroundColor = [UIColor lightGrayColor];
}
*/

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TGCommentVC *commentVc = [[TGCommentVC alloc] init];
    commentVc.topic = self.topics[indexPath.row];
    [self.navigationController pushViewController:commentVc animated:YES];
}

@end
