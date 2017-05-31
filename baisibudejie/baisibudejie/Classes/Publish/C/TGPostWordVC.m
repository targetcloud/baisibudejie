//
//  TGPostWordVC.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/21.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGPostWordVC.h"
#import "TGPlaceholderTextV.h"
#import "TGAddToolBar.h"

@interface TGPostWordVC ()<UITextViewDelegate>
@property (nonatomic, weak) TGPlaceholderTextV *textV;
@property (nonatomic, weak) TGAddToolBar *toolBar;
@end

@implementation TGPostWordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBase];
    [self setupTextView];
    [self setupToolBar];
}

- (void)setupBase{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"发表段子";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"发表" style:UIBarButtonItemStyleDone target:self action:@selector(post)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.navigationController.navigationBar layoutIfNeeded];
}

- (void)setupTextView{
    TGPlaceholderTextV *textView = [[TGPlaceholderTextV alloc] init];
    textView.placeholder = @"把好玩的图片，好笑的段子或糗事发到这里，接受千万网友膜拜吧!😁";
    textView.frame = self.view.bounds;
    textView.delegate = self;
    [self.view addSubview:textView];
    _textV = textView;
}

- (void)setupToolBar{
    TGAddToolBar *toolBar = [TGAddToolBar viewFromXIB];
    [self.view addSubview:toolBar];
    _toolBar = toolBar;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillChageFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyBoardWillChageFrame:(NSNotification *)note{
    CGRect keyBoadrFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat animKey = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    [UIView animateWithDuration:animKey animations:^{
        self.toolBar.transform = CGAffineTransformMakeTranslation(0,keyBoadrFrame.origin.y - ScreenH);
    }];
    
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    _toolBar.width = self.view.width;
    _toolBar.y = self.view.height - _toolBar.height;
}

- (void)cancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)post{
    TGFunc
}

- (void)textViewDidChangeSelection:(UITextView *)textView{
    self.navigationItem.rightBarButtonItem.enabled = textView.hasText;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.view endEditing:YES];
    [self.textV becomeFirstResponder];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}
@end
