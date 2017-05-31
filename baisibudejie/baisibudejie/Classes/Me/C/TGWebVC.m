//
//  TGWebVC.m
//  baisibudejie
//
//  Created by targetcloud on 2017/3/7.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGWebVC.h"
#import <WebKit/WebKit.h>

@interface TGWebVC ()
@property (weak, nonatomic) IBOutlet UIView *contentV;
@property (weak, nonatomic) IBOutlet WKWebView *webV;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardItem;
@property (weak, nonatomic) IBOutlet UIProgressView *progressV;
@end

@implementation TGWebVC

- (IBAction)goBack:(id)sender {
    [self.webV goBack];
}

- (IBAction)goForward:(id)sender {
    [self.webV goForward];
}

- (IBAction)reload:(id)sender {
    [self.webV reload];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    _webV.frame = self.contentV.bounds;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    WKWebView *webView = [[WKWebView alloc] init];
    _webV = webView;
    [self.contentV addSubview:webView];
    NSURLRequest *request = [NSURLRequest requestWithURL:_url];
    [webView loadRequest:request];
    [webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    self.backItem.enabled = self.webV.canGoBack;
    self.forwardItem.enabled = self.webV.canGoForward;
    self.title = self.webV.title;
    self.progressV.progress = self.webV.estimatedProgress;
    self.progressV.hidden = self.webV.estimatedProgress >= 1;
}

- (void)dealloc{
    [self.webV removeObserver:self forKeyPath:@"canGoBack"];
    [self.webV removeObserver:self forKeyPath:@"title"];
    [self.webV removeObserver:self forKeyPath:@"canGoForward"];
    [self.webV removeObserver:self forKeyPath:@"estimatedProgress"];
}

@end
