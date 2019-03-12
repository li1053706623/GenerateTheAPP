//
//  DIYScanResultViewController.m
//  AiDiEr
//
//  Created by Apple on 2019/2/14.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "DIYScanResultViewController.h"
#import "RefreshLoadingView.h"

@interface DIYScanResultViewController ()<WKUIDelegate,WKNavigationDelegate>
/**********文字************/
@property (nonatomic,strong) UILabel *resultLabel;
/**********内容************/
@property (nonatomic,strong) EwenCopyLabel *resultContentLabel;

@property(nonatomic,strong)WKWebView *webView;

@property(nonatomic,strong)RefreshLoadingView *loadingView;

@property(nonatomic,strong)NSTimer *timer;

@end

@implementation DIYScanResultViewController

-(UILabel *)resultLabel{
    if (!_resultLabel) {
        _resultLabel = [[UILabel alloc]init];
        _resultLabel.textColor = [UIColor blackColor];
        _resultLabel.text = @"扫描到以下内容";
        _resultLabel.font = [UIFont systemFontOfSize:15];
        _resultLabel.numberOfLines = 0;
    }
    return _resultLabel;
}
-(EwenCopyLabel *)resultContentLabel{
    if (!_resultContentLabel) {
        _resultContentLabel = [[EwenCopyLabel alloc]init];
        _resultContentLabel.text = self.result;
       _resultContentLabel.textColor = [UIColor blackColor];
        _resultContentLabel.textAlignment = NSTextAlignmentCenter;
        _resultContentLabel.backgroundColor = [UIColor whiteColor];
        _resultContentLabel.font = [UIFont systemFontOfSize:17];
        _resultContentLabel.numberOfLines = 0;
    }
    return _resultContentLabel;
}

- (WKWebView *)webView{
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:self.view.frame];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _webView.contentMode = UIViewContentModeRedraw;
        _webView.opaque = YES;
        _webView.UIDelegate =self;
        _webView.navigationDelegate = self;
        _webView.allowsBackForwardNavigationGestures = YES;
        _webView.opaque = NO;
        _webView.multipleTouchEnabled = YES;
//        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        
    }
    return _webView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];
   
    
    [self.navigationController.navigationBar navBarBackGroundColor:[UIColor whiteColor] image:nil isOpaque:YES];
    [self.navigationController.navigationBar navBarMyLayerHeight:64 isOpaque:YES];
    [self.navigationController.navigationBar navBarBottomLineHidden:NO];
    [self.navigationController.navigationBar navBarAlpha:1 isOpaque:YES];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:[NSString stringWithFormat:@"%@",@"#000000"]]}];
    
    [self GoBackWithString:@"back_black"];
    
    
    self.title = @"扫描结果";
    
//    NSLog(@"-----%d",[self isUrl:self.result]);
    
    if ([self isUrl:self.result] == YES) {
        [self loadUrl];

//      [self urliSAvailable:self.result];

    }else{

        [self loadScanResult];
//        self.resultLabel.text = self.result;
    }
    
    __weak typeof(self)weakSelf = self;
    
    [self.view addSlideWithSwipeGestureRecognizerDirection:UISwipeGestureRecognizerDirectionRight EventBlock:^(id  _Nonnull obj) {
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    }];
    

    
}

-(void)loadUrl{
    
    self.loadingView = [[RefreshLoadingView alloc]init];
    self.loadingView.backgroundColor = [UIColor blackColor];
    self.loadingView.alpha = 0.9;
    self.loadingView.hidden = NO;
    [self.view addSubview:self.loadingView];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 100));
    }];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.result]]];
    [self.view addSubview:self.webView];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//       self.timer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(Timered) userInfo:nil repeats:YES];
//        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
//         [[NSRunLoop currentRunLoop] run];
//    });
}

-(void)Timered{
    [self.timer invalidate];
    self.timer = nil;
    self.loadingView.hidden = YES;
    [YJProgressHUD showMessage:@"请检查网络是否连接或网址是否正确" inView:self.view];

    
}
-(void)loadScanResult{
    [self.view addSubview:self.resultLabel];
    [self.resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.view).mas_offset(150);
    }];

    UIView *contentView = [[UIView alloc]init];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.resultLabel.mas_bottom).mas_offset(5);
        make.leading.mas_equalTo(self.view.mas_leading).mas_equalTo(10);
        make.trailing.mas_equalTo(self.view.mas_trailing).mas_equalTo(-10);
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_equalTo(-20);
    }];
    
    [contentView addSubview:self.resultContentLabel];
    [self.resultContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(contentView.mas_centerX);
        make.top.mas_equalTo(contentView.mas_top).mas_equalTo(10);
    }];
    
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
    self.loadingView.hidden = YES;
     NSLog(@"---%@",@"加载成功");
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"---%@",error.description);
}

- (void)urliSAvailable:(NSString *)urlStr{
    
   
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
     [request setHTTPMethod:@"HEAD"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"无效的URL地址");
//            [self showAlertViewContrllerWithMessage:@"无效的URL地址"];
        }else{
            NSLog(@"成功");
//             [self loadUrl];
//             Available = YES;
        }
    }];
    
    [task resume];
}

@end
