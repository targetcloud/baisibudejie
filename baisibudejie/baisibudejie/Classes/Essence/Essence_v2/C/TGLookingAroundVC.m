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
//#import <AFNetworking.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import "TGNetworkTools.h"

@interface TGLookingAroundVC ()<UICollectionViewDataSource,UICollectionViewDelegate, TGLayoutDelegate>
@property (nonatomic, strong) NSMutableArray<TGTopicNewM *> *topics;
//@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSMutableDictionary *params;
@property (nonatomic, assign) NSInteger lastSelectedIndex;
@property (nonatomic, weak) UICollectionView *collectionV;

@property (nonatomic ,weak) TGRefreshOC *refresh;
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

//- (AFHTTPSessionManager *)manager{
//    if (!_manager) {
//        _manager = [AFHTTPSessionManager manager];
//    }
//    return _manager;
//}

-(NSString *) requesturl :(NSString *) nextpage{
    //http://s.budejie.com/topic/list/zuixin/31/bs0315-iphone-4.5.6/0-20.json
    return [NSString stringWithFormat:@"http://s.budejie.com/topic/list/zuixin/31/bs0315-iphone-4.5.6/%@-20.json",nextpage];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    _np = @"0";
    self.view.backgroundColor = TGGrayColor(246);
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
    //[self.manager invalidateSessionCancelingTasks:YES];
    //[[TGNetworkTools sharedTools] invalidateSessionCancelingTasks:YES];
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
    /*
    self.collectionV.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewTopics)];
    self.collectionV.mj_header.automaticallyChangeAlpha = YES;
    [self.collectionV.mj_header beginRefreshing];
    */
    
    //换用自己的刷新控件
    TGRefreshOC *refresh = [TGRefreshOC new];
    refresh.kind = RefreshKindNormal;
    //refresh.bgColor =  [UIColor colorWithWhite:0.8 alpha:1];
    refresh.verticalAlignment = TGRefreshAlignmentMidden;
    refresh.automaticallyChangeAlpha = YES;
    refresh.refreshResultTextColor = [UIColor whiteColor];
    refresh.refreshResultBgColor = [[UIColor redColor] colorWithAlphaComponent:0.6];
    [self.collectionV addSubview:refresh];
    _refresh = refresh;
    [refresh addTarget:self action:@selector(loadNewTopics) forControlEvents:UIControlEventValueChanged];
    [refresh beginRefreshing];
    
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
            //[self.collectionV.mj_header endRefreshing];
            [self.refresh endRefreshing];
            return;
        }
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
        self.refresh.refreshResultStr = [NSString stringWithFormat:@"成功刷新到%zd条数据",self.topics.count];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.refresh endRefreshing];
        });
        [self.collectionV reloadData];
        //[self.collectionV.mj_header endRefreshing];
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
//        [self.collectionV reloadData];
//        [self.collectionV.mj_header endRefreshing];
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        if (self.params != parameters) return ;
//        if (error.code != NSURLErrorCancelled) { // 并非是取消任务导致的error，其他网络问题导致的error
//            [SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试！"];
//        }
//        [self.collectionV.mj_header endRefreshing];
//    }];
}

- (void)loadMoreTopics{
    [self.collectionV.mj_header endRefreshing];
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
            [self.collectionV.mj_footer endRefreshing];
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
        [self.collectionV reloadData];
        [self.collectionV.mj_footer endRefreshing];
    }];
    
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
//        [self.collectionV reloadData];
//        [self.collectionV.mj_footer endRefreshing];
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        if (self.params != parameters) return ;
//        if (error.code != NSURLErrorCancelled) { // 并非是取消任务导致的error，其他网络问题导致的error
//            [SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试！"];
//        }
//        [self.collectionV.mj_footer endRefreshing];
//    }];
}

- (void)setupLayout{
    TGLayout *layout = [[TGLayout alloc] init];
    layout.delegate = self;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.backgroundColor = TGGrayColor(246);
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

-(void)getNextLikeIndexWithTopicId :(NSString *)topicId :(void(^)(NSInteger nextLikeIndex))block{
    __block NSInteger next = -1;
    __block NSInteger index = -1;
    __block NSInteger first = -1;
    __weak typeof(self)weakSelf = self;
    [weakSelf.topics enumerateObjectsUsingBlock:^(TGTopicNewM * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isLikeSelected){
            first = (first == -1) ? idx : first;
            index = ([obj.ID isEqualToString:topicId]) ? idx : index;
            next = (idx > index && index > -1) ? idx : next;
            *stop = (idx > index && index > -1);
        }
    }];
    next = (next == -1) ? first : next;
    block(next);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TGLookingAroundV *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TGCollectionViewCellId forIndexPath:indexPath];
    cell.topic = self.topics[indexPath.item];
    __weak typeof(self)weakSelf = self;
    __weak typeof(cell)weakCell = cell;
    [cell setCommentBlock:^(NSString * topicId){
        TGCommentNewVC *commentVc = [[TGCommentNewVC alloc] init];
        [weakSelf.topics[indexPath.row] setShowAllWithoutComment:YES];
        commentVc.topic = weakSelf.topics[indexPath.row];
        [weakSelf.navigationController pushViewController:commentVc animated:YES];
    }];
    
    [cell setNextBlock:^(NSString * topicId){//循环播放喜欢，喜欢的在界面则动画切到喜欢的cell上，若不在，则直接替换playerItem
        //1 拿位置
        [self getNextLikeIndexWithTopicId:topicId :^(NSInteger nextLikeIndex) {
            if (nextLikeIndex > -1){
                //2 判断位置在不在界面上 indexPathsForVisibleItems visibleCells均可拿到
                //NSArray *arr = [weakSelf.collectionV indexPathsForVisibleItems];
                NSArray *arr2 = [weakSelf.collectionV visibleCells];
                //TGLog(@"%@ %@",arr,arr2)
                //for (NSIndexPath * path in arr){
                //    TGLog(@"%@",path)
                //}
                
                //在界面上
                for (TGLookingAroundV * obj in arr2) {
                    NSIndexPath *path = (NSIndexPath *)[weakSelf.collectionV indexPathForCell:obj];
                    //TGLog(@"%@",path)
                    if (nextLikeIndex == path.item){
                        [obj play];
                        return;
                    }
                }
                //不在界面上
                [weakCell replacePlayerItem:weakSelf.topics[nextLikeIndex]];
            }
        }];
    }];
    
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

//-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    //TGFunc
//    TGCommentNewVC *commentVc = [[TGCommentNewVC alloc] init];
//    [self.topics[indexPath.row] setShowAllWithoutComment:YES];
//    commentVc.topic = self.topics[indexPath.row];
//    [self.navigationController pushViewController:commentVc animated:YES];
//}


-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    TGLookingAroundV * voiceCell =  (TGLookingAroundV *)cell;
    if (!voiceCell.topic.isAnimated){
        //TGLog(@"frame %@",NSStringFromCGRect(cell.frame))
        //效果1
        //cell.transform = CGAffineTransformScale(cell.transform, 0.5, 0.5);
        //效果2
        //cell.transform = CGAffineTransformTranslate(cell.transform, 0, cell.height);
        //效果3
        if (cell.x == 0) {
            cell.transform = CGAffineTransformTranslate(cell.transform, -ScreenW * 0.25, 0);
        }else{
            cell.transform = CGAffineTransformTranslate(cell.transform, ScreenW * 0.5, 0);
        }
        
        //效果4
//        if (cell.x == 0) {
//            cell.layer.transform = CATransform3DMakeRotation(-M_PI_2, 0, 0, 1.0);
//        }else{
//            cell.layer.transform = CATransform3DMakeRotation(M_PI_2, 0, 0, 1.0);
//        }
        
        cell.alpha = 0.0;
        [UIView animateWithDuration:0.6 animations:^{
            cell.transform = CGAffineTransformIdentity;
            cell.layer.transform = CATransform3DIdentity;
            cell.alpha = 1.0;
            voiceCell.topic.animated = YES;
        } completion:^(BOOL finished) {
        }];
    }
}

@end
