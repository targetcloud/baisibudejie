//
//  TGLookingAroundVC.m
//  baisibudejie
//
//  Created by targetcloud on 2017/6/9.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGLookingAroundVC.h"
#import "TGLookingAroundV.h"
#import "TGTopicNewM.h"
#import "TGLayout.h"
#import "TGCommentNewVC.h"
#import <MJRefresh.h>
#import <AFNetworking.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>

@interface TGLookingAroundVC ()<UICollectionViewDataSource,UICollectionViewDelegate, TGLayoutDelegate>
@property (nonatomic, strong) NSMutableArray<TGTopicNewM *> *topics;
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSMutableDictionary *params;
@property (nonatomic, assign) NSInteger lastSelectedIndex;
@property (nonatomic, weak) UICollectionView *collectionV;
@end

static NSString * const TGCollectionViewCellId = @"LookingAroundCellId";

@implementation TGLookingAroundVC
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

- (AFHTTPSessionManager *)manager{
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}

-(NSString *) requesturl :(NSString *) nextpage{
    //http://s.budejie.com/topic/list/zuixin/31/bs0315-iphone-4.5.6/0-20.json
    return [NSString stringWithFormat:@"http://s.budejie.com/topic/list/zuixin/31/bs0315-iphone-4.5.6/%@-20.json",nextpage];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _np = @"0";
    self.view.backgroundColor = TGGrayColor(206);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabBarButtonDidRepeatClick) name:TabBarButtonDidRepeatClickNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(titleButtonDidRepeatClick) name:TitleButtonDidRepeatClickNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustTableViewContentInsetWithHidden) name:NavigationBarHiddenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustTableViewContentInsetWithShow) name:NavigationBarShowNotification object:nil];
    [self setupLayout];
    [self setupRefresh];
}

-(void)adjustTableViewContentInsetWithHidden{
    if (self.view.superview.tag != 9999){
        self.collectionV.contentInset = UIEdgeInsetsMake( NavMaxY , 0, TabBarH, 0);
    }
    self.collectionV.scrollIndicatorInsets = self.collectionV.contentInset;
}

-(void) adjustTableViewContentInsetWithShow{
    if (self.view.superview.tag != 9999){
        self.collectionV.contentInset = UIEdgeInsetsMake( NavMaxY + TitleVH, 0, TabBarH, 0);
    }
    self.collectionV.scrollIndicatorInsets = self.collectionV.contentInset;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.manager invalidateSessionCancelingTasks:YES];
}

- (void)tabBarButtonDidRepeatClick{
    if (self.view.window == nil) return;
    if (self.collectionV.scrollsToTop == NO) return;
    if (self.lastSelectedIndex == self.tabBarController.selectedIndex
        //&& self.tabBarController.selectedViewController == self.navigationController
        && self.view.isShowingOnKeyWindow) {
        TGFunc
        [self.collectionV.mj_header beginRefreshing];
    }
    self.lastSelectedIndex = self.tabBarController.selectedIndex;
}

- (void)titleButtonDidRepeatClick{
    [self tabBarButtonDidRepeatClick];
}

- (void)setupRefresh{
    self.collectionV.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewTopics)];
    self.collectionV.mj_header.automaticallyChangeAlpha = YES;
    [self.collectionV.mj_header beginRefreshing];
    self.collectionV.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTopics)];
    self.collectionV.mj_footer.hidden = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y > _contentOffsetY){
        if (scrollView.contentOffset.y > 0){
            if((scrollView.contentOffset.y - _contentOffsetY) > _contentOffsetSpeed && _contentOffsetSpeed>20){
                [[NSNotificationCenter defaultCenter] postNotificationName:NavigationBarHiddenNotification object:nil userInfo:nil];
            }
            _contentOffsetSpeed = scrollView.contentOffset.y - _contentOffsetY;
        }
    }else{
        if (scrollView.contentOffset.y > 0){
            if (_contentOffsetY - scrollView.contentOffset.y > _contentOffsetSpeed && _contentOffsetSpeed>20){
                [[NSNotificationCenter defaultCenter] postNotificationName:NavigationBarShowNotification object:nil userInfo:nil];
            }
            _contentOffsetSpeed = _contentOffsetY - scrollView.contentOffset.y;
        }else if (fabs(scrollView.contentOffset.y) > NavMaxY && fabs(scrollView.contentOffset.y) < NavMaxY+TitleVH){
            [[NSNotificationCenter defaultCenter] postNotificationName:NavigationBarShowNotification object:nil userInfo:nil];
        }
    }
    _contentOffsetY = scrollView.contentOffset.y;
}

- (void)loadNewTopics{
    [self.collectionV.mj_footer endRefreshing];
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    self.params = parameters;
    [self.manager GET:[self requesturl:@"0"] parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        if (self.params != parameters) return ;
        AFNWriteToPlist(new_topics)
        _np = responseObject[@"info"][@"np"];
        self.topics = [TGTopicNewM mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
        //过滤html
        [self.topics enumerateObjectsUsingBlock:^(TGTopicNewM * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.type isEqualToString:@"html"]){
                [self.topics removeObject:obj];
            }
        }];
        [self.collectionV reloadData];
        [self.collectionV.mj_header endRefreshing];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (self.params != parameters) return ;
        if (error.code != NSURLErrorCancelled) { // 并非是取消任务导致的error，其他网络问题导致的error
            [SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试！"];
        }
        [self.collectionV.mj_header endRefreshing];
    }];
}

- (void)loadMoreTopics{
    [self.collectionV.mj_header endRefreshing];
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    self.params = parameters;
    [self.manager GET:[self requesturl:_np] parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
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
        [self.collectionV reloadData];
        [self.collectionV.mj_footer endRefreshing];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (self.params != parameters) return ;
        if (error.code != NSURLErrorCancelled) { // 并非是取消任务导致的error，其他网络问题导致的error
            [SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试！"];
        }
        [self.collectionV.mj_footer endRefreshing];
    }];
}

- (void)setupLayout{
    TGLayout *layout = [[TGLayout alloc] init];
    layout.delegate = self;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.backgroundColor = TGGrayColor(206);
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [self.view addSubview:collectionView];
    
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([TGLookingAroundV class]) bundle:nil] forCellWithReuseIdentifier:TGCollectionViewCellId];
    
    self.collectionV = collectionView;
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    self.collectionV.mj_footer.hidden = self.topics.count == 0;
    return self.topics.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TGLookingAroundV *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TGCollectionViewCellId forIndexPath:indexPath];
    cell.topic = self.topics[indexPath.item];
//    __weak typeof(self)weakSelf = self;
//    [cell setCommentBlock:^(NSString * topicId){
//        TGCommentNewVC *commentVc = [[TGCommentNewVC alloc] init];
//        [weakSelf.topics[indexPath.row] setShowAllWithoutComment:YES];
//        commentVc.topic = weakSelf.topics[indexPath.row];
//        [weakSelf.navigationController pushViewController:commentVc animated:YES];
//    }];
    return cell;
}

#pragma mark - <TGLayoutDelegate>
- (CGFloat)layout:(TGLayout *)layout heightForItemAtIndex:(NSUInteger)index itemWidth:(CGFloat)itemWidth{
    TGTopicNewM *topic = self.topics[index];
    return itemWidth * topic.height / topic.width;
}

- (CGFloat)rowMarginInLayout:(TGLayout *)layout{
    return 2;
}

- (CGFloat)columnMarginInLayout:(TGLayout *)layout{
    return 2;
}

- (CGFloat)columnCountInLayout:(TGLayout *)layout{
    return 2;
}

- (UIEdgeInsets)edgeInsetsInLayout:(TGLayout *)layout{
    return UIEdgeInsetsMake(2, 0, 0, 0);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //TGFunc
    TGCommentNewVC *commentVc = [[TGCommentNewVC alloc] init];
    [self.topics[indexPath.row] setShowAllWithoutComment:YES];
    commentVc.topic = self.topics[indexPath.row];
    [self.navigationController pushViewController:commentVc animated:YES];
}

@end
