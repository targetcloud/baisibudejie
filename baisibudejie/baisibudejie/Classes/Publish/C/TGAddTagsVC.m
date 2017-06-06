//
//  TGAddTagsVC.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/21.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGAddTagsVC.h"
#import "TGTagBtn.h"
#import "TGTagTextField.h"
#import <SVProgressHUD.h>

@interface TGAddTagsVC ()<UITextFieldDelegate>
@property (weak , nonatomic)UIView *contentV;
@property (weak , nonatomic)TGTagTextField *textField;
@property (weak , nonatomic)UIButton *addBtn;
@property (strong , nonatomic)NSMutableArray *tagBtns;
@end

@implementation TGAddTagsVC

#pragma mark - 懒加载
- (UIButton *)addBtn{
    if (!_addBtn) {
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addButton.width = self.contentV.width;
        addButton.height = 35;
        addButton.layer.masksToBounds = YES;
        addButton.layer.cornerRadius = 5;
        addButton.backgroundColor = TagTitleColor;//TagBgColor;
        addButton.titleLabel.font = TagFont;
        [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(addBtnClick) forControlEvents:UIControlEventTouchUpInside];
        addButton.contentEdgeInsets = UIEdgeInsetsMake(0, TagMargin, 0, TagMargin);
        addButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.contentV addSubview:addButton];
        _addBtn = addButton;
    }
    return _addBtn;
}

- (NSMutableArray *)tagBtns{
    if (!_tagBtns) {
        _tagBtns = [NSMutableArray array];
    }
    return _tagBtns;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.view endEditing:YES];
    [self.textField becomeFirstResponder];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBase];
    [self setupContentView];
    [self setupTextField];
    [self setupTags];
}

- (void)setupBase{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"添加标签";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
}

- (void)setupContentView{
    UIView *contentView = [[UIView alloc] init];
    contentView.frame = CGRectMake(Margin, 64 + Margin, self.view.width - 2 * Margin, ScreenH);
    [self.view addSubview:contentView];
    _contentV = contentView;
}

- (void)setupTextField{
    TGTagTextField *textField = [[TGTagTextField alloc] init];
    textField.width = self.contentV.width;
    [textField becomeFirstResponder];
    textField.delegate = self;
    __weak typeof(self)weakSelf = self;
    textField.deleteBlock = ^{
        if (weakSelf.textField.hasText) return;
        [weakSelf tagBtnClick:[weakSelf.tagBtns lastObject]];
    };
    [textField addTarget:self action:@selector(textFieldContentDidChange) forControlEvents:UIControlEventEditingChanged];
    [_contentV addSubview:textField];
    _textField = textField;
}

- (void)setupTags{
    for (NSString *tag in self.tags) {
        self.textField.text = tag;
        [self addBtnClick];
    }
}

#pragma mark - 点击完成按钮事件
- (void)done{
    NSArray *tags = [_tagBtns valueForKeyPath:@"currentTitle"];
    !_tagsBlock ? : _tagsBlock(tags);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 监听文字的改变
- (void)textFieldContentDidChange{
    if (_textField.hasText) {
        _addBtn.hidden = NO;
        _addBtn.y = CGRectGetMaxY(self.textField.frame) + TagMargin;
        [self.addBtn setTitle:[NSString stringWithFormat:@"添加标签：%@",_textField.text] forState:UIControlStateNormal];
        
        NSString *text = self.textField.text;
        NSUInteger length = text.length;
        NSString *lastNSstring = [text substringFromIndex:length - 1];
        if (([lastNSstring isEqualToString:@","] || [lastNSstring isEqualToString:@"，"]) && length > 1)  {
            self.textField.text = [text substringToIndex:length - 1];
            [self addBtnClick];
        }
    }else{
        _addBtn.hidden = YES;
    }
    [self updateTagButtonAndTextFieldFrame];
}

#pragma mark - 监听添加标签按钮点击
- (void)addBtnClick{
    if (_tagBtns.count == 9) {
        [SVProgressHUD showErrorWithStatus:@"最多添加9个标签哦！"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    TGTagBtn *tagBtn = [TGTagBtn buttonWithType:UIButtonTypeCustom];
    [tagBtn addTarget:self action:@selector(tagBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [tagBtn setTitle:self.textField.text forState:UIControlStateNormal];
    tagBtn.height = self.textField.height;
    [self.contentV addSubview:tagBtn];
    [self.tagBtns addObject:tagBtn];
    self.textField.text = nil;
    self.addBtn.hidden = YES;
    [self updateTagButtonAndTextFieldFrame];
}

- (void)updateTagButtonAndTextFieldFrame{
    for (NSInteger i = 0; i < _tagBtns.count; i++ ) {
        UIButton *tagBtn = self.tagBtns[i];
        if (i == 0) {
            tagBtn.x = 0;
            tagBtn.y = 0;
        }else{
            UIButton *lastTagBtn = self.tagBtns[i - 1];
            CGFloat leftWidth = CGRectGetMaxX(lastTagBtn.frame) + TagMargin;
            CGFloat rightWidth = self.contentV.width - leftWidth - TagMargin;
            if (rightWidth >= tagBtn.width) {
                tagBtn.y = lastTagBtn.y;
                tagBtn.x = leftWidth;
            }else{
                tagBtn.x = 0;
                tagBtn.y = CGRectGetMaxY(lastTagBtn.frame) + TagMargin;
            }
        }
    }
    
    UIButton *lastTagBtn = [self.tagBtns lastObject];
    CGFloat leftWidth = CGRectGetMaxX(lastTagBtn.frame) + TagMargin;
    if (self.contentV.width - leftWidth -TagMargin >= [self textFieldWidth]) {
        self.textField.x = leftWidth;
        self.textField.y = lastTagBtn.y;
    }else{
        self.textField.x = 0;
        self.textField.y = CGRectGetMaxY(lastTagBtn.frame) + TagMargin;
    }
    _addBtn.y = CGRectGetMaxY(self.textField.frame) + TagMargin;
    self.textField.placeholder = (self.tagBtns.count == 0) ? @"输入标签,标签打得好,精华上得早!" :
                                                             @"多个标签用换行或者逗号隔开!";
}

- (CGFloat)textFieldWidth{
    CGFloat textWidth =  [self.textField.text.length > 0 ? self.textField.text : self.textField.placeholder sizeWithAttributes:@{NSFontAttributeName : self.textField.font}].width;
    return MAX(100, textWidth);//100已经没用了，有文字按文字，否则按占位文字，最后如果连占位文字都没有才会是最小100宽来计算
}

- (void)tagBtnClick:(TGTagBtn *)tagBtn{
    [tagBtn removeFromSuperview];
    [self.tagBtns removeObject:tagBtn];
    [UIView animateWithDuration:0.25 animations:^{
        [self updateTagButtonAndTextFieldFrame];
    }];
}

- (BOOL)textFieldShouldReturn:(TGTagTextField *)textField{
    if (textField.hasText) {
        [self addBtnClick];
    }
    return YES;
}

@end
